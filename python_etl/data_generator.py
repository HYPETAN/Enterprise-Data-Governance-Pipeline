import pyodbc
from faker import Faker
import random
import datetime

# ==========================================
# CONFIGURATION
# ==========================================
# We updated the Server to 'localhost\MSSQLSERVER01' based on your screenshot.
CONN_STR = (
    r'Driver={ODBC Driver 18 for SQL Server};'
    r'Server=localhost\MSSQLSERVER01;'
    r'Database=EnterpriseDiveDB;'
    r'Trusted_Connection=yes;'
    r'TrustServerCertificate=yes;'
)

fake = Faker()


def generate_and_load_data(num_records=1000):
    print(f"--- STARTING ETL PIPELINE SIMULATION ---")
    print(f"Target Server: localhost\MSSQLSERVER01")

    try:
        # 1. Connect to SQL Server
        conn = pyodbc.connect(CONN_STR)
        cursor = conn.cursor()
        print("Connected to Database successfully.")

        # 2. Generate Synthetic Data (Batch Insert)
        print(f"Generating {num_records} records (95% Valid / 5% 'Dirty')...")

        insert_query = """
            INSERT INTO Staging.Raw_Divers (Raw_First, Raw_Last, Raw_Email, Raw_DOB)
            VALUES (?, ?, ?, ?)
        """

        batch_data = []

        for _ in range(num_records):
            fname = fake.first_name()
            lname = fake.last_name()

            # SIMULATE DATA QUALITY ISSUES (The "Real World" Problem)
            # 5% chance to generate a bad record to test our Quarantine logic
            if random.random() < 0.05:
                # Case A: Invalid Email Format
                email = f"{fname}.{lname}_at_gmail.com"
                # Case B: Invalid Date (e.g., 'Unknown')
                dob = "Unknown Date"
            else:
                # Valid Data
                email = fake.email()
                dob = fake.date_of_birth(minimum_age=18, maximum_age=70)

            batch_data.append((fname, lname, email, str(dob)))

        # 3. Load into STAGING (Bronze Layer)
        cursor.executemany(insert_query, batch_data)
        conn.commit()
        print(
            f"Successfully loaded {num_records} records into 'Staging.Raw_Divers'.")

        # 4. Trigger the Governance Pipeline (Stored Procedure)
        print("Executing Stored Procedure: sp_Load_Divers_From_Staging...")
        cursor.execute("EXEC sp_Load_Divers_From_Staging")
        conn.commit()
        print("Governance Logic Applied.")

        # 5. Report Results (Verification)
        print("\n--- PIPELINE REPORT ---")

        # Check Production (Valid Data)
        cursor.execute("SELECT COUNT(*) FROM Diver")
        valid_count = cursor.fetchone()[0]
        print(f"Records Promoted to Production (Silver Layer): {valid_count}")

        # Check Quarantine (Bad Data)
        cursor.execute("SELECT COUNT(*) FROM dbo.Data_Quarantine")
        invalid_count = cursor.fetchone()[0]
        print(
            f"Records Rejected to Quarantine (Bad Data):      {invalid_count}")

        # Verify Temporal History (Audit)
        # Note: Since you are on SQL 2022 now, this table exists!
        cursor.execute("SELECT COUNT(*) FROM Diver_History")
        history_count = cursor.fetchone()[0]
        print(
            f"Audit Trail Entries (Temporal History):        {history_count}")

        conn.close()
        print("\n--- SUCCESS ---")

    except pyodbc.Error as ex:
        print(f"\n[CRITICAL ERROR] SQL Connection Failed.")
        print(f"Message: {ex}")
        print("Tip: Ensure you have executed the SQL setup scripts (01-06) on the NEW server instance.")


if __name__ == "__main__":
    generate_and_load_data(1000)
