# MySQL-Generate-CSharp-Models
MySQL(v5.x supported an tested may work on other MySQL versions but not guarnteed) Stored procedure to geneate C# model class and data access code from existing MySQL Database tables 

MySQL Stored procedure to generate C# Model Classes and Data Access layer code block to help generate models afster from existing MySQL DB tables. Each table is exported as single C# class.

Review(most important) and execute the "GenerateCSharpModels.sql" file in you mysql TEST/DEV/UAT server to create new stored procedure named "GenerateCSharpModels".
Then just execute "CALL GenerateCSharpModels();" to get the table with C# data model classes and DAL helper code.

PS: MySQL v5.x supported and tested may work on other MySQL versions but not guarnteed. In case not working just take a look at your MySQL version equivalent syntax and modify the procedure accordingly. Cheers!
Please feel free to use and share this code as you wish.

