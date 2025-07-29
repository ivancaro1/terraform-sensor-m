import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.sql import functions as F
from pyspark.sql.window import Window

# === Job initialization ===
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'input_path',
    'output_path'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

input_path = args['input_path']
output_path = args['output_path']

# === Load input data ===
df = spark.read.format("parquet").load(input_path)

# === Cast timestamp fields ===
df = df.withColumn("sensor_timestamp", F.to_timestamp("sensor_timestamp"))
df = df.withColumn("gateway_tm", F.to_timestamp("gateway_tm"))

# === Filter and rank ===
df_not_null = df.filter(F.col("temperature").isNotNull())
window_spec = Window.partitionBy("mac").orderBy(F.col("sensor_timestamp").desc())
df_ranked = df_not_null.withColumn("row_num", F.row_number().over(window_spec))

# === Flag latest record ===
df_yes_flag = df_ranked.filter(F.col("row_num") == 1) \
    .select("mac", "sensor_timestamp") \
    .withColumn("is_latest_valid_temp", F.lit("yes"))

df_no_flag = df.drop("is_latest_valid_temp")

df_with_flag = df_no_flag.join(
    df_yes_flag,
    on=["mac", "sensor_timestamp"],
    how="left"
).withColumn(
    "is_latest_valid_temp",
    F.when(F.col("is_latest_valid_temp").isNull(), F.lit("no")).otherwise(F.col("is_latest_valid_temp"))
)

# === Write result ===
df_with_flag.write \
    .mode("overwrite") \
    .format("parquet") \
    .option("path", output_path) \
    .saveAsTable("gluedatabasetest.adv_gateway")

print("✅ Flag 'is_latest_valid_temp' actualizado correctamente.")
job.commit()