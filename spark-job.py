from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date

# Create Spark session
spark = SparkSession.builder.appName("TestSparkJob").getOrCreate()

# Create test DataFrame
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
columns = ["name", "age"]
df = spark.createDataFrame(data, columns)

# Add current date column
df_with_date = df.withColumn("process_date", current_date())

# Show results
print("=== Test Spark Job Results ===")
df_with_date.show()

# Count records
record_count = df_with_date.count()
print(f"Total records processed: {record_count}")

spark.stop()
print("Spark job completed successfully!")
