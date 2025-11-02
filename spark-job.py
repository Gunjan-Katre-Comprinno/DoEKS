from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date, lit
from datetime import datetime

# Create Spark session with Spark 4.0.0 optimizations
spark = SparkSession.builder \
    .appName("TestSparkJob") \
    .config("spark.sql.adaptive.enabled", "true") \
    .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
    .config("spark.sql.adaptive.skewJoin.enabled", "true") \
    .getOrCreate()

# Create test DataFrame
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
columns = ["name", "age"]
df = spark.createDataFrame(data, columns)

# Add current date column
df_with_date = df.withColumn("process_date", current_date())

# Show results
print("=== Test Spark Job Results ===")
print(f"Job executed at: {datetime.now()}")  
df_with_date.show()

# Count records
record_count = df_with_date.count()
print(f"Total records processed: {record_count}")

spark.stop()
print("Spark job completed successfully!")
