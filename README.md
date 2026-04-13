# court-vision-warehouse 🏀  
**A Python-first, SQL Server warehouse for NBA shot analytics using medallion architecture**

## 📌 Project Brief  
This project builds a local-to-cloud data warehouse for NBA shot data using the `nba_api`.  
Data flows from raw ingestion to final data marts through layered transforms and quality checks, all orchestrated via Airflow and modeled with dbt.

## 🧱 Tech Stack  
| Component     | Tool                  | Purpose                                         |
|---------------|-----------------------|-------------------------------------------------|
| Cloud DB      | Azure SQL Database    | Hosts raw, staging, warehouse, and mart schemas |
| Extraction    | Python + nba_api      | Pull, dedupe, and load API data into raw layer  |
| Transform     | dbt-core + dbt-sqlserver | In-database modeling & tests               |
| Orchestration | Apache Airflow        | DAGs to schedule and monitor ETL               |
| Containers    | Docker + docker-compose | Local stack for Airflow, dbt, extractors     |
| Testing       | dbt tests + pytest    | Data quality checks + unit tests               |
| Auth          | Azure AD (planned)    | Secure access to Azure SQL                     |
| CI            | GitHub Actions        | Lint, test, and image builds                   |

## 📂 Repo Structure  

court-vision-whse/
├─ orchestration/ # Airflow DAGs and compose config
├─ etl/ # Python extractor package (nba_api → raw.*)
├─ dbt/ # dbt-sqlserver project
├─ ge/ # Great Expectations (optional)
├─ docs/ # Diagrams, runbooks, README
├─ .github/workflows/ # GitHub Actions (CI)
├─ scripts/ # Helper/local bootstrap scripts
└─ tests/ # Unit tests (pytest)


## 🚀 Status  
Phase 0: Dev tooling and baseline repo setup ✅  
Phase 1: Setup up Azure Database, create baseline schemas
Phase 2: Create constellation design, create raw layer tables


## Documentation

All design and architecture documentation lives in the [`docs/`](./docs) folder:

- **blueprint.md** → Conceptual and logical data warehouse design (ERD, grain, schema).
- **raw_layer.md** → Raw ingestion layer design, policies, and rationale.
- Future docs → Staging, marts, orchestration notes.

This separation keeps the **project repo** clean: SQL/ETL code is under `sql/` and `dags/`, while design decisions and architecture live in `docs/`.