import sys
import boto3
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.functions import input_file_name
from pyspark.sql.window import Window
from pyspark.sql.types import *

# === Obtener argumentos dinámicos ===
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'RAW_BUCKET',
    'CURATED_BUCKET',
    'processed_key',
    'output_path'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# === Parámetros dinámicos ===
input_bucket = args['RAW_BUCKET']
input_prefix = "data/"
processed_bucket = args['CURATED_BUCKET']
processed_key = args['processed_key']
output_path = args['output_path']

s3 = boto3.client('s3')

# === Leer archivos procesados previos ===
def get_processed_files():
    try:
        obj = s3.get_object(Bucket=processed_bucket, Key=processed_key)
        content = obj['Body'].read().decode('utf-8')
        return set(line.strip() for line in content.splitlines() if line.strip())
    except s3.exceptions.NoSuchKey:
        return set()

# === Guardar lista de archivos procesados ===
def save_processed_files(file_set):
    content = "\n".join(sorted(file_set))
    s3.put_object(Bucket=processed_bucket, Key=processed_key, Body=content.encode('utf-8'))

# === Listar archivos .json no vacíos ===
all_files = []
continuation_token = None

while True:
    kwargs = {
        'Bucket': input_bucket,
        'Prefix': input_prefix
    }
    if continuation_token:
        kwargs['ContinuationToken'] = continuation_token

    response = s3.list_objects_v2(**kwargs)
    contents = response.get('Contents', [])
    all_files.extend([obj['Key'] for obj in contents if obj['Key'].endswith('.json') and obj['Size'] > 0])

    if response.get('IsTruncated'):
        continuation_token = response.get('NextContinuationToken')
    else:
        break

# === Detectar nuevos archivos ===
processed_files = get_processed_files()
new_keys = [key for key in all_files if key not in processed_files]
new_files = [f"s3://{input_bucket}/{key}" for key in new_keys]

if not new_files:
    print("No new files to process.")
    job.commit()

print(f"Nuevos archivos detectados: {len(new_files)}")

# === Esquema explícito ===
schema = StructType([
    StructField("gw", StringType(), True),
    StructField("tm", StringType(), True),
    StructField("adv", ArrayType(
        StructType([
            StructField("type", StringType(), True),
            StructField("battery", IntegerType(), True),
            StructField("ver", StringType(), True),
            StructField("screen", StringType(), True),
            StructField("product", StringType(), True),
            StructField("rssi", IntegerType(), True),
            StructField("tm", StringType(), True),
            StructField("mac", StringType(), True),
            StructField("temperature", DoubleType(), True),
            StructField("x_axis", DoubleType(), True),
            StructField("y_axis", DoubleType(), True),
            StructField("z_axis", DoubleType(), True),
            StructField("block_id", ArrayType(IntegerType()), True)
        ])
    ), True)
])

# === Transformaciones ===
df = spark.read.option("multiline", "true").schema(schema).json(new_files)
df = df.withColumn("source_file", input_file_name())
df = df.withColumn("adv", F.explode("adv"))

df_flat = df.select(
    F.col("gw"),
    F.col("adv.mac").alias("mac"),
    F.col("adv.temperature").alias("temperature"),
    F.col("adv.tm").alias("sensor_timestamp"),
    F.col("adv.rssi").cast("int"),
    F.col("adv.battery").alias("sensor_battery"),
    F.col("tm").alias("gateway_tm"),
    F.col("adv.type").alias("adv_type"),
    F.col("source_file")
)

df_flat = df_flat.withColumn("sensor_timestamp", F.to_timestamp("sensor_timestamp"))
df_flat = df_flat.withColumn("gateway_tm", F.to_timestamp("gateway_tm"))

df_valid_temp = df_flat.filter(F.col("temperature").isNotNull())

window_spec = Window.partitionBy("mac").orderBy(F.col("sensor_timestamp").desc())
df_ranked = df_valid_temp.withColumn("row_num", F.row_number().over(window_spec))
df_yes_flag = df_ranked.filter(F.col("row_num") == 1).select("mac", "sensor_timestamp").withColumn("is_latest_valid_temp", F.lit("yes"))

df_with_flag = df_flat.join(
    df_yes_flag,
    on=["mac", "sensor_timestamp"],
    how="left"
).withColumn(
    "is_latest_valid_temp",
    F.when(F.col("is_latest_valid_temp").isNull(), F.lit("no")).otherwise(F.col("is_latest_valid_temp"))
)

# === Guardar en Glue Table ===
df_with_flag.write \
    .mode("append") \
    .format("parquet") \
    .option("path", output_path) \
    .saveAsTable("gluedatabasetest.adv_gateway")

# === Guardar nuevos archivos procesados ===
processed_files.update(new_keys)
save_processed_files(processed_files)
print("processed_files.txt actualizado.")
job.commit()
print("Job finalizado correctamente.")