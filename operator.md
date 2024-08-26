## Azure Elastic Pool for SQL Server

Azure Elastic Pool for SQL Server is a cost-effective solution to manage and scale multiple databases that have varying and unpredictable resource demands. Elastic pools help to manage the performance and cost of your databases effectively by allocating resources dynamically to where they are most needed.

### Design Decisions

1. **Resource Group and Naming**: Each resource is named with a prefix specified by metadata to ensure unique and identifiable naming within the resource group.
2. **Identity and Authentication**: Utilizes system-assigned managed identity for secure access and role assignments.
3. **Storage and Auditing**: Integrated with Azure Storage for auditing purposes, allowing easy tracking and analysis of database access and activity.
4. **Monitoring and Alerts**: Implements metric-based alerts for critical performance indicators such as CPU usage, DTU percentage, and storage usage for proactive monitoring and management.
5. **Networking**: Configured with virtual network rules and firewall rules to secure database access.

### Runbook

#### Connectivity Issues

If you are unable to connect to your MSSQL server, it's essential to check the network configuration including firewall settings.

```sh
# Check firewall rules for the MSSQL server
az sql server firewall-rule list --resource-group <RESOURCE_GROUP> --server <SERVER_NAME>
```

You should see a list of firewall rules. Ensure that the IP address from which you are trying to connect is allowed.

#### High CPU Usage

If you observe high CPU usage for elastic pools running in vCore model, the following commands can help identify issues:

```sh
# Monitor CPU usage metrics of the elastic pool
az monitor metrics list --resource <RESOURCE_ID> --metric "cpu_percent" --aggregation "Average"
```

This command will output the average CPU percent usage which can be used to analyze any spikes or periods of high usage.

#### High DTU Usage

For elastic pools running in the DTU model, high DTU consumption can degrade performance:

```sh
# Monitor DTU consumption metrics
az monitor metrics list --resource <RESOURCE_ID> --metric "dtu_consumption_percent" --aggregation "Average"
```

This will provide the DTU consumption percentage, helping you understand resource utilization patterns.

#### Storage Usage

When storage usage is high, it's critical to ensure that there is adequate storage:

```sh
# Monitor storage usage metrics
az monitor metrics list --resource <RESOURCE_ID> --metric "storage_percent" --aggregation "Average"
```

This will display the storage usage percentage which can be informative to prevent storage-related issues.

#### Query Performance Issues

For performance issues related to specific queries, use SQL queries to analyze execution plans and identify inefficiencies:

```sql
-- Find queries consuming the most resources
SELECT TOP 10 
    [total_worker_time] / [execution_count] AS [Avg CPU Time], 
    [total_worker_time] AS [Total CPU Time],
    [execution_count], 
    SUBSTRING([text], (statement_start_offset/2)+1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH([text])
        ELSE statement_end_offset
     END - statement_start_offset)/2) + 1) AS [Query Text]
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text([sql_handle]) 
ORDER BY [Total CPU Time] DESC;
```

This will help identify and optimize the most resource-intensive queries.

#### Auditing Issues

If auditing is not capturing expected data, ensure your auditing policy is correctly configured:

```sh
# Check the server auditing policy
az sql server audit-policy show --resource-group <RESOURCE_GROUP> --server <SERVER_NAME>
```

This will provide the existing audit policy details which can be reviewed and adjusted if necessary. 

#### Insufficient Permissions

If users encounter permission errors, review role assignments:

```sh
# Check role assignments for the MSSQL server
az role assignment list --scope <SERVER_RESOURCE_ID>
```

Ensure the necessary roles are assigned to users who need access.

By following these troubleshooting steps, you can effectively manage and resolve common issues with Azure Elastic Pool for SQL Server.


