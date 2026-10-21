# Step 1 · Lesson 1: The Snowflake skeleton

**Time:** about 3–4 hours. **Files:** `01_setup.sql` and `01_experiments.sql`.

## 1. Question

Before we load any data, we need to answer this: *where does the data live, what compute processes it, and who is allowed to touch it?*

Right now everything runs as `ACCOUNTADMIN` on `COMPUTE_WH` in one database. That works for a demo. A real pipeline needs to separate:

| Concern | Snowflake object | What we create |
|---|---|---|
| Where data lives | Database / schema | `RAW.SHOP`, then `ANALYTICS` (built by dbt) |
| What computes | Warehouse | `LOADING_WH`, `TRANSFORMING_WH` |
| Who can do what | Role | `LOADER`, `TRANSFORMER`, `REPORTER` |
| How much it costs | Resource monitor | `LEARNING_MONITOR` (10 credits per month) |

The flow we're building toward looks like this:

```
CSV files --(LOADER, LOADING_WH)--> RAW.SHOP --(dbt as TRANSFORMER, TRANSFORMING_WH)--> ANALYTICS --(REPORTER)--> dashboards
```

## 2. Hypothesis

Write your answers down *before* you run anything:

1. Logged in as `REPORTER`, will you be able to see the `RAW` database?
2. As `LOADER`, can you create a table in `ANALYTICS`? Can you create one in `RAW.SHOP`?
3. Does a warehouse keep running, and costing credits, after a query finishes?

## 3. Experiment

1. If you don't have a Snowflake account yet, create a free trial at signup.snowflake.com. Pick the Enterprise edition and any cloud or region. You get $400 of credits, which is far more than this course needs.
2. Open a new SQL worksheet in Snowsight and paste `01_setup.sql` into it. Read each comment, then run the whole worksheet.
3. Paste `01_experiments.sql` into a second worksheet and run it **one block at a time**.

## 4. Analysis

Compare what actually happened with your hypotheses:

- **A:** `REPORTER` only sees `ANALYTICS`. In Snowflake you can't see an object unless your role has a privilege on it. "Not visible" and "access denied" come from the same rule.
- **B:** The first `CREATE` fails, and the second one succeeds. This is least privilege in practice. If a buggy loading script ran as `LOADER`, it physically could not damage your dbt models.
- **C:** The warehouse switches to `STARTED`, then goes back to `SUSPENDED` about 60 seconds later because of `AUTO_SUSPEND`. You pay per second while it's running, with a 60-second minimum each time it resumes. Storage is billed separately and is cheap.

Also look at the `SHOW GRANTS` output at the end of the setup script. Can you explain each line in your own words?

## 5. Conclusion: what you should now be able to explain

- Why storage and compute are separate in Snowflake, and why that lets you have two warehouses on the same data.
- Why `RAW` is never edited by hand: you can always rebuild `ANALYTICS` from it.
- What a **future grant** is, and why dbt needs one. dbt creates new tables every run, and those tables didn't exist when we ran the grants.
- Why you should avoid using `ACCOUNTADMIN` day to day.

**Next lesson:** load the four CSVs into `RAW.SHOP` the proper way, with a file format, a stage, and `COPY INTO`. We'll also deliberately break a file to see how Snowflake reports load errors.
