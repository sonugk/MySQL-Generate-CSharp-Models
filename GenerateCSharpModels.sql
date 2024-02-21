CREATE DEFINER=`root`@`%` PROCEDURE `GenCSharpModel`(in pTableName VARCHAR(255), in pSchemaName VARCHAR(255))
BEGIN
DECLARE vClassName varchar(255);
declare vClassCode mediumtext;
declare vClassDAL mediumtext;
declare v_codeChunk varchar(1024);
declare vClassDALchunk varchar(1024);

DECLARE v_finished INTEGER DEFAULT 0;
DEClARE code_cursor CURSOR FOR 
    SELECT code,ccode FROM temp1; 

DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET v_finished = 1;

set vClassCode ='';

    SELECT Concat((CASE WHEN col1 = col2 THEN col1 ELSE concat(col1,col2)  END),'DTO') into vClassName
    FROM(
    SELECT CONCAT(UCASE(MID(ColumnName1,1,1)),LCASE(MID(ColumnName1,2))) as col1,
    CONCAT(UCASE(MID(ColumnName2,1,1)),LCASE(MID(ColumnName2,2))) as col2
    FROM
    (SELECT SUBSTRING_INDEX(pTableName, '_', -1) as ColumnName2,
        SUBSTRING_INDEX(pTableName, '_', 1) as ColumnName1) A) B;

    
    CREATE TEMPORARY TABLE IF NOT EXISTS  temp1 ENGINE=MyISAM  
    as (
    select concat( 'public ', ColumnType , ' ' , FieldName,' { get; set; }') as code,
    concat('obj.',FieldName,' = dr["',FieldName,'"] == DBNull.Value ? ',Csharpcode,'(dr["',FieldName,'"]);') as ccode
    FROM(
    SELECT (CASE WHEN col1 = col2 THEN col1 ELSE concat(col1,col2)  END) AS FieldName, 
    case DATA_TYPE 
            when 'bigint' then 'long'
            when 'binary' then 'byte[]'
            when 'bit' then 'bool'
            when 'char' then 'string'
            when 'date' then (Case IS_NULLABLE When 'YES' Then 'DateTime?' Else 'DateTime' End)
            when 'datetime' then (Case IS_NULLABLE When 'YES' Then 'DateTime?' Else 'DateTime' End)
            when 'datetime2' then (Case IS_NULLABLE When 'YES' Then 'DateTime?' Else 'DateTime' End)
            when 'datetimeoffset' then 'DateTimeOffset'
            when 'decimal' then 'decimal'
            when 'float' then 'float'
            when 'image' then 'byte[]'
            when 'int' then 'int'
            when 'money' then 'decimal'
            when 'nchar' then 'char'
            when 'ntext' then 'string'
            when 'numeric' then 'decimal'
            when 'nvarchar' then 'string'
            when 'real' then 'double'
            when 'smalldatetime' then 'DateTime'
            when 'smallint' then 'short'
            when 'mediumint' then 'INT'
            when 'smallmoney' then 'decimal'
            when 'text' then 'string'
            when 'time' then 'TimeSpan'
            when 'timestamp' then (Case IS_NULLABLE When 'YES' Then 'DateTime?' Else 'DateTime' End)
            when 'tinyint' then 'byte'
            when 'uniqueidentifier' then 'string'
            when 'varbinary' then 'byte[]'
            when 'varchar' then 'string'
            when 'year' THEN 'INT16'
            else 'UNKNOWN_' + DATA_TYPE
        end ColumnType,
        case DATA_TYPE 
            when 'bigint' then '0L : Convert.ToInt64'
            when 'bit' then 'false : Convert.ToBoolean'
            when 'char' then '"" : Convert.ToString'
            when 'date' then (Case IS_NULLABLE When 'YES' Then '(DateTime?)null : Convert.ToDateTime' Else 'DateTime.Now : Convert.ToDateTime' End)
            when 'datetime' then (Case IS_NULLABLE When 'YES' Then '(DateTime?)null : Convert.ToDateTime' Else 'DateTime.Now : Convert.ToDateTime' End)
            when 'datetime2' then (Case IS_NULLABLE When 'YES' Then '(DateTime?)null : Convert.ToDateTime' Else 'DateTime.Now : Convert.ToDateTime' End)
            when 'decimal' then '0 : Convert.ToDecimal'
            when 'float' then '0 : Convert.ToDecimal'
            when 'int' then '0 : Convert.ToInt32'
            when 'money' then '0 : Convert.ToDecimal'
            when 'nchar' then '"" : Convert.ToString'
            when 'ntext' then '"" : Convert.ToString'
            when 'numeric' then '0 : Convert.ToDecimal'
            when 'nvarchar' then '"" : Convert.ToString'
            when 'real' then '0 : Convert.ToDecimal'
            when 'smalldatetime' then (Case IS_NULLABLE When 'YES' Then '(DateTime?)null : Convert.ToDateTime' Else 'DateTime.Now : Convert.ToDateTime' End)
            when 'smallint' then '0 : Convert.ToInt16'
            when 'mediumint' then '0 : Convert.ToInt32'
            when 'smallmoney' then '0 : Convert.ToDecimal'
            when 'text' then '"" : Convert.ToString'
            when 'time' then (Case IS_NULLABLE When 'YES' Then '(DateTime?)null : Convert.ToDateTime' Else 'DateTime.Now : Convert.ToDateTime' End)
            when 'timestamp' then (Case IS_NULLABLE When 'YES' Then 'DateTime?' Else 'DateTime' End)
            when 'tinyint' then 'byte'
            when 'uniqueidentifier' then '"" : Convert.ToString'
            when 'varchar' then '"" : Convert.ToString'
            when 'year' THEN '0 : Convert.ToInt16'
            else 'UNKNOWN_' + DATA_TYPE
        end Csharpcode
    FROM(
    select CONCAT(UCASE(MID(ColumnName1,1,1)),LCASE(MID(ColumnName1,2))) as col1,
    CONCAT(UCASE(MID(ColumnName2,1,1)),LCASE(MID(ColumnName2,2))) as col2,
    
    DATA_TYPE,IS_NULLABLE
    from
    (SELECT COLUMN_NAME as ColumnName2,
    COLUMN_NAME as ColumnName1,
    DATA_TYPE, COLUMN_TYPE,IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS  WHERE table_name = pTableName and table_schema=pSchemaName) A) B)C);

    set vClassCode = '';
    set vClassDAL = '';
    
    
    OPEN code_cursor;
 
            get_code: LOOP
         
                FETCH code_cursor INTO v_codeChunk,vClassDALchunk;
         
                IF v_finished = 1 THEN 
                    LEAVE get_code;
                END IF;
                
                
                select  CONCAT(vClassCode,'', v_codeChunk),CONCAT(vClassDAL,'', vClassDALchunk) into  vClassCode,vClassDAL ;
         
            END LOOP get_code;
     
        CLOSE code_cursor;

drop table temp1;

select concat('public class ',vClassName,'{', vClassCode,'}');
Select vClassDAL;
END
