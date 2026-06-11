# Rental Performance Analysis

Analysis of the MySQL Sakila sample database (a DVD rental store) using plain SQL. The script answers operational questions a rental business would ask: who rents the most, what gets rented longest, which titles move, which customers are worth the most, and how staff perform.

<img align="center" src=https://user-images.githubusercontent.com/111542025/229187731-b3a7895b-2733-4908-8482-c45d6a856ca4.jpg>

## Business problem

> Data source: the [sakila](https://dev.mysql.com/doc/sakila/en/) sample database from MySQL.

The Sakila sample database was originally developed by Mike Hillyer of the MySQL AB documentation team. It models a fictional DVD rental company (stores, staff, customers, film inventory, rentals, and payments) and is widely used for SQL examples and tutorials. For background, see the [Sakila introduction](https://dev.mysql.com/doc/sakila/en/sakila-introduction.html).

Against that schema, this project produces a set of rental performance breakdowns across frequency, duration, customer value, inventory popularity, and employee performance.

## Business assumptions

- The data provided is complete and was stored correctly.
- Sakila intends to develop a service closer to the customer in the future, so customer-level breakdowns matter.
- The DVD rental industry is in decline, but that is out of scope here; the goal is to analyze this company's own data as given.

## What the script computes

The script ([`rental_performance_analysis.sql`](rental_performance_analysis.sql)) is organized into five analysis sections.

1. Rental frequency
   - By customer (top 10 renters).
   - By staff member.
   - By store, attributed via inventory ownership (`inventory.store_id`), so it counts rentals of each store's stock rather than rentals processed by each store's clerks.
2. Rental duration (average days between rental and return)
   - By customer, by film, and by film category.
   - By store city, and separately by customer city. These are kept distinct on purpose: store city has only two values in Sakila (the two store locations), while customer city is the more meaningful geographic view.
3. Customer segmentation
   - By rental frequency, by average rental duration, and by total revenue (sum of payments).
4. Inventory popularity
   - Rental count per film title, most to least rented.
5. Employee performance
   - Rentals processed per staff member and their average rental duration.

Each query groups by the primary key (for example `customer_id`, `staff_id`) and shows a readable label, so two people who happen to share a name are never merged into a single row.

## How to run

1. Install MySQL (the server, plus the `mysql` CLI or MySQL Workbench).
2. Load the Sakila sample database. Download `sakila-db` from the [Sakila page](https://dev.mysql.com/doc/sakila/en/), then load the schema before the data:
   ```bash
   mysql -u <user> -p < sakila-schema.sql
   mysql -u <user> -p < sakila-data.sql
   ```
3. Run this analysis script (it begins with `USE sakila;`):
   ```bash
   mysql -u <user> -p < rental_performance_analysis.sql
   ```
   Or open `rental_performance_analysis.sql` in MySQL Workbench and execute each section.

The script is read-only. It runs `SELECT` queries only and does not modify the database.

### Validate the SQL without a database

To check that the script parses cleanly before running it against a server, use the included static validator (no database required):

```bash
pip install -r requirements.txt
python validate_sql.py
```

It parses every statement under the MySQL dialect with `sqlglot` and exits non-zero if anything fails to parse.

## Results

No query outputs are committed to this repository, so no numbers are quoted here to avoid publishing figures that were not captured from a real run. Running the script against a loaded Sakila instance (see "How to run") reproduces every breakdown listed above. A future update can paste a few real outputs (for example the top customer by rentals and the average duration by category) once they are captured from an actual run.

## Possible next steps

- Capture real query outputs and record them in this README.
- Build a Power BI or similar dashboard on top of these queries.
- Add inventory turnover and a simple customer-value (RFM-style) segmentation.
