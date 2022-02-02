
SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';


-- BESPOKE USER GROUPS

INSERT IGNORE INTO `hpapi_usergroup` (`usergroup`, `level`, `name`, `password_self_manage`, `notes`) VALUES

('swimlanes',	100000,	'Swimlanes user',	1,	'Common swimlanes user group for access.');

-- HPAPI PRIVILEGE TABLES (THINGS YOU CAN DO)

--         Expose vendor-repository/package-directory to the API

INSERT IGNORE INTO `hpapi_package` (`vendor`, `package`, `requires_key`, `notes`) VALUES

('whitelamp-ezproject',	'swimlanes-server',	0,	'Swimlanes Kanban software');


--         Expose \NameSpace\ClassName::methodName () to the API

INSERT IGNORE INTO `hpapi_method` (`vendor`, `package`, `class`, `method`, `label`, `notes`) VALUES

('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'authenticate',	'More user details',	'Dummy method to authenticate'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'statuses',	'List status options',	'List of Kanban states'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimlanes',	'List of swimlanes',	'List of swimlanes - groups of swims - available to user'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimmers',	'List swimmers',	'List of swimpool users'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims',	'List swims',	'List of swims - atomic tasks - for a given status');



--         Define \NameSpace\ClassName::method (arguments)

INSERT IGNORE INTO `hpapi_methodarg` (`vendor`, `package`, `class`, `method`, `argument`, `name`, `empty_allowed`, `pattern`) VALUES

('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimlanes',	1,	'Swimpool code',	0,	'varchar-4'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims',	1,	'Swimpool code',	0,	'varchar-4'),
('whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims',	2,	'Swimlane code',	0,	'varchar-4');



--         Expose \NameSpace\ClassName::methodName () to user group

INSERT IGNORE INTO `hpapi_run` (`usergroup`, `vendor`, `package`, `class`, `method`) VALUES

('swimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'authenticate'),
('swimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'statuses'),
('swimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimlanes'),
('swimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimmers'),
('swimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims');



--    DATA LAYER EXPOSURE

--         Expose DataModel to the API

INSERT IGNORE INTO `hpapi_model` (`model`, `notes`) VALUES

('EzProject',	'Model for EzProject (including Swimlanes).'),
('HpapiModel', 'Model for the API itself.');


--         Expose DataModel.storedProcedureName to the API

INSERT IGNORE INTO `hpapi_spr` (`model`, `spr`, `notes`) VALUES

('HpapiModel',	'ezpSwimlanesUsers',	'Swimmers with associated swimpools'),
('EzProject',	'ezpSwimlanesStatuses',	'State of a swim - Kanban states'),
('EzProject',	'ezpSwimlanesSwimlanes',	'Swimlanes'),
('EzProject',	'ezpSwimlanesSwimpools',	'Swimpools - groups of swimlanes'),
('EzProject',	'ezpSwimlanesSwims',	'Swims - atomic tasks');


--         Define DataModel.storedProcedureName arguments

INSERT IGNORE INTO `hpapi_sprarg` (`model`, `spr`, `argument`, `name`, `empty_allowed`, `pattern`) VALUES

('EzProject',	'ezpSwimlanesSwimlanes',	1,	'Email',	0,	'email'),
('EzProject',	'ezpSwimlanesSwimlanes',	2,	'Swimpool code',	0,	'varchar-4'),
('HpapiModel',	'ezpSwimlanesUsers',	1,	'User ID',	1,	'int-11-positive');


--         Expose DataModel.storedProcedureName to \NameSpace\ClassName::methodName ()

INSERT IGNORE INTO `hpapi_call` (`model`, `spr`, `vendor`, `package`, `class`, `method`) VALUES

('HpapiModel',	'ezpSwimlanesUsers',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'authenticate'),
('HpapiModel',	'ezpSwimlanesUsers',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimmers'),
('EzProject',	'ezpSwimlanesStatuses',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'statuses'),
('EzProject',	'ezpSwimlanesSwimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimlanes'),
('EzProject',	'ezpSwimlanesSwimlanes',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims'),
('EzProject',	'ezpSwimlanesSwimpools',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'authenticate'),
('EzProject',	'ezpSwimlanesSwimpools',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swimmers'),
('EzProject',	'ezpSwimlanesSwims',	'whitelamp-ezproject',	'swimlanes-server',	'\\EzProject\\Swimlanes',	'swims');




-- HPAPI PERMISSION TABLES (DATA YOU CAN MODIFY DIRECTLY)

--     DATA LAYER EXPOSURE



--         Expose server-side tableName.columnName to the API

INSERT IGNORE INTO `hpapi_column` (`table`, `column`, `model`, `pattern`, `empty_allowed`, `empty_is_null`) VALUES

('ezp_blah',	'some_column',	'EzProject',	'varchar-64',	0,	0);



--         Allow user group to insert tuples into a column (inserts deploy SQL_MODE='STRICT_ALL_TABLES')

INSERT IGNORE INTO `hpapi_insert` (`usergroup`, `table`, `column`) VALUES

('swimlanes',	'ezp_blah',	'some_column');



--         Allow user group to update tuple in a column (Hpapi inserts enforce SQL_MODE='STRICT_ALL_TABLES')

INSERT IGNORE INTO `hpapi_update` (`usergroup`, `table`, `column`) VALUES

('swimlanes',	'ezp_blah',	'some_column'),
('swimlanes',	'ezp_blah',	'deleted'); -- Gives logical delete/undelete capability; Hpapi does not use SQL DELETE statements


