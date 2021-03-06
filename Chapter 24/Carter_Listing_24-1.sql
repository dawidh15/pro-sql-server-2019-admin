CREATE RESOURCE POOL ReportingApp
    WITH(
        MIN_CPU_PERCENT=50, 
        MAX_CPU_PERCENT=80, 
        MIN_IOPS_PER_VOLUME = 20,
        MAX_IOPS_PER_VOLUME = 100
        ) ;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE ;
GO
