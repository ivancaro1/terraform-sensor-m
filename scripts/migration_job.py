import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from pyspark.sql.functions import col
from awsglue.utils import getResolvedOptions

# === Recibir argumentos dinámicos ===
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'source_path',
    'target_path'
])

# === Inicializa el contexto de Glue y Spark ===
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# === Rutas S3 de entrada y salida ===
source_path = args['source_path']
target_path = args['target_path']

# === Leer los archivos Parquet desde la carpeta fuente ===
df = spark.read.parquet(source_path)

# === Convertir columnas a tipo timestamp si existen ===
timestamp_cols = ["sensor_timestamp", "receive_timestamp", "last_updated"]
for col_name in timestamp_cols:
    if col_name in df.columns:
        df = df.withColumn(col_name, col(col_name).cast("timestamp"))

# === Imprime el esquema para depuración (opcional) ===
df.printSchema()

# === Escribir los datos transformados en la nueva ubicación ===
df.write.mode("overwrite").parquet(target_path)

print("✅ Migración completada exitosamente.")