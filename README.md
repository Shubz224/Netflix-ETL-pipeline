# Netflix Data Analytics Pipeline

![Flow](/public/home.png) 

## 🎯 Project Overview

This repository contains a comprehensive data transformation pipeline built with **dbt (Data Build Tool)** and **Snowflake** for analyzing Netflix/MovieLens dataset. The pipeline transforms raw movie ratings, genome tags, and movie metadata into a structured data warehouse following dimensional modeling principles.

## 🏗️ Architecture

### Technology Stack
- **Data Warehouse**: Snowflake
- **Transformation Tool**: dbt (Data Build Tool)
- **Data Modeling**: Dimensional modeling with star schema
- **Version Control**: Git
- **Documentation**: dbt docs

### Data Flow Architecture
```
Raw Data (Snowflake) → Staging Layer → Dimensional Layer → Fact Tables
```

## 📊 Data Sources

The pipeline processes the following raw datasets from the `MOVIELENS.RAW` schema:

| Table | Description | Key Columns |
|-------|-------------|-------------|
| `RAW_MOVIES` | Movie catalog with titles and genres | movieId, title, genres |
| `RAW_RATINGS` | User ratings for movies | userId, movieId, rating, timestamp |
| `RAW_GENOME_TAGS` | Tag definitions for movie genome | tagId, tag |
| `RAW_GENOME_SCORES` | Relevance scores for movie-tag pairs | movieId, tagId, relevance |
| `RAW_LINKS` | External links (IMDb, TMDb) | movieId, imdbId, tmdbId |
| `RAW_TAGS` | User-generated tags | userId, movieId, tag, timestamp |

## 🏛️ Data Model

### Staging Layer (`staging/`)
Staging models perform initial data cleaning and standardization:

- **`src_movies`**: Standardizes movie data with proper column naming
- **`src_ratings`**: Converts timestamps and cleans rating data
- **`src_genome_tags`**: Normalizes tag definitions
- **`src_genome_score`**: Processes genome relevance scores
- **`src_links`**: Standardizes external link references
- **`src_tags`**: Processes user-generated tags with timestamp conversion

![Lingage Graph](/public/lingageGraph.png) 

### Dimensional Layer (`dim/`)
Dimension tables for analytical queries:

- **`dim_movies`**: 
  - Clean movie catalog with title formatting
  - Genre array parsing for multi-genre analysis
  - Materialized as `table`

- **`dim_users`**: 
  - Unified user dimension from ratings and tags
  - Ensures referential integrity
  - Materialized as `table`

- **`dim_genome_tags`**: 
  - Standardized tag definitions
  - Proper case formatting
  - Materialized as `table`

### Fact Layer (`fct/`)
Fact tables containing measurable events:

- **`fct_ratings`**: 
  - User movie ratings with timestamps
  - **Incremental model** for performance optimization
  - Materialized as `table`
  - Incremental strategy based on `rating_timestamp`

- **`fct_genome_scores`**: 
  - Movie-tag relevance scores
  - Filtered for relevance > 0
  - Rounded to 4 decimal places
  - Materialized as `table`

## 🚀 Getting Started

### Prerequisites
- Snowflake account with appropriate permissions
- dbt installed (version 1.0+)
- Access to `MOVIELENS.RAW` schema

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd netflix
   ```

2. **Install dbt dependencies**
   ```bash
   dbt deps
   ```

3. **Configure dbt profile**
   Update your `~/.dbt/profiles.yml`:
   ```yaml
   netflix:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: <your-account>
         user: <your-username>
         password: <your-password>
         role: <your-role>
         database: <your-database>
         warehouse: <your-warehouse>
         schema: <your-schema>
   ```

4. **Test connection**
   ```bash
   dbt debug
   ```

### Running the Pipeline

1. **Full pipeline execution**
   ```bash
   dbt run
   ```

2. **Run specific layer**
   ```bash
   # Staging layer only
   dbt run --select staging
   
   # Dimensional layer only
   dbt run --select dim
   
   # Fact layer only
   dbt run --select fct
   ```

3. **Incremental updates**
   ```bash
   # For incremental fact tables
   dbt run --select fct_ratings
   ```

4. **Run tests**
   ```bash
   dbt test
   ```

## 📈 Key Features

### Performance Optimizations
- **Incremental Loading**: `fct_ratings` uses incremental materialization for efficient updates
- **Proper Materialization**: Views for staging, tables for dimensions and facts
- **Filtered Data**: Genome scores filtered for relevance > 0 to reduce storage

### Data Quality
- **Data Cleaning**: INITCAP and TRIM functions for consistent formatting
- **Referential Integrity**: Unified user dimension ensures data consistency
- **Timestamp Conversion**: Proper timezone handling with `TO_TIMESTAMP_LTZ`

### Analytical Capabilities
- **Genre Analysis**: Array-based genre storage for multi-genre movies
- **User Behavior**: Comprehensive user activity tracking
- **Content Tagging**: Genome-based content analysis
- **Temporal Analysis**: Timestamp preservation for time-based analytics

## 📁 Project Structure

```
netflix/
├── analyses/              # Ad-hoc analytical queries
├── dbt_project.yml       # dbt project configuration
├── macros/               # Reusable SQL macros
├── models/
│   ├── staging/          # Source data standardization
│   │   ├── src_movies.sql
│   │   ├── src_ratings.sql
│   │   ├── src_genome_tags.sql
│   │   ├── src_genome_score.sql
│   │   ├── src_links.sql
│   │   └── src_tags.sql
│   ├── dim/              # Dimensional tables
│   │   ├── dim_movies.sql
│   │   ├── dim_users.sql
│   │   └── dim_genome_tags.sql
│   └── fct/              # Fact tables
│       ├── fct_ratings.sql
│       └── fct_genome_scores.sql
├── seeds/                # Static reference data
├── snapshots/            # SCD Type 2 implementations
├── tests/                # Data quality tests
└── README.md
```

## 🔧 Configuration

### Model Configurations
- **Staging**: Materialized as views for cost efficiency
- **Dimensions**: Materialized as tables for query performance
- **Facts**: Materialized as tables with incremental loading where applicable

### Incremental Strategy
The `fct_ratings` table uses incremental materialization:
- **Strategy**: Append new records based on timestamp
- **Trigger**: `rating_timestamp > MAX(rating_timestamp)`
- **Failure Handling**: `on_schema_change = 'fail'`

## 🧪 Testing Strategy

### Recommended Tests
```sql
-- Example tests to implement
-- Test for data uniqueness
-- Test for referential integrity
-- Test for data freshness
-- Test for accepted value ranges
```

## 📊 Business Use Cases

This pipeline enables analysis for:
- **Content Recommendation**: Using genome scores and user preferences
- **User Segmentation**: Based on rating patterns and behavior
- **Content Performance**: Movie popularity and rating trends
- **Genre Analysis**: Multi-genre movie categorization
- **Temporal Patterns**: Rating behavior over time

## 🔄 Deployment

### Development Workflow
1. Create feature branch
2. Develop and test models locally
3. Run `dbt run` and `dbt test`
4. Create pull request
5. Deploy to production after approval

### Production Considerations
- Schedule regular incremental runs for fact tables
- Monitor data quality with automated testing
- Implement alerting for pipeline failures
- Document model changes and business logic

## 📚 Additional Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [MovieLens Dataset](https://grouplens.org/datasets/movielens/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
