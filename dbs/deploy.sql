SET TARGET_DATABASE   = '<% dbsname %>';
SET DEPLOY_SCHEMA     = '<% depname %>';
SET DEPLOY_ROLE_OWNER = 'APP_<% depname %>_OWNER';
SET APP_ROLE_TYPE_01  = 'APP_<% depname %>_ROL01';
SET APP_ROLE_TYPE_02  = 'APP_<% depname %>_ROL02';
SET APP_NB_CONTROL    = 'APP_<% depname %>_CONTROL';
SET SERVICE_NAME      = 'APP_<% depname %>_SVC';
SET SERVICE_RUN_USER  = 'APP_<% depname %>_USER';
SET SERVICE_RUN_POOL  = 'APP_<% depname %>_POOL';
SET SERVICE_RUN_VWHS  = 'APP_<% depname %>_WH';
SET EXT_ACC_INT_NAME  = 'APP_<% depname %>_EXASINT';
SET EXT_ACC_NET_RULE  = 'APP_<% depname %>_NETRULE';


---------------------------------------------------------------------------------
USE ROLE IDENTIFIER($DEPLOY_ROLE_OWNER);
USE DATABASE IDENTIFIER($TARGET_DATABASE);
USE SCHEMA IDENTIFIER($DEPLOY_SCHEMA);
USE WAREHOUSE IDENTIFIER($SERVICE_RUN_VWHS);

LIST @SPECS PATTERN='.*yaml';
REMOVE @SPECS PATTERN='.*yaml';
PUT file://img/service.yaml @SPECS AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 

LIST @VOLUMES PATTERN='.*gz';
REMOVE @VOLUMES PATTERN='.*gz';
PUT file://app.tar.gz @VOLUMES AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 

DESC COMPUTE POOL IDENTIFIER($SERVICE_RUN_POOL);
--ALTER COMPUTE POOL IF EXISTS IDENTIFIER($SERVICE_RUN_POOL) SUSPEND;
ALTER COMPUTE POOL IF EXISTS IDENTIFIER($SERVICE_RUN_POOL) RESUME IF SUSPENDED;

ALTER SERVICE IF EXISTS IDENTIFIER($SERVICE_NAME) SUSPEND;
--ALTER SERVICE IF EXISTS IDENTIFIER($SERVICE_NAME) RESUME;

DROP SERVICE IF EXISTS IDENTIFIER($SERVICE_NAME) FORCE;
CREATE SERVICE IDENTIFIER($SERVICE_NAME)
  IN COMPUTE POOL IDENTIFIER($SERVICE_RUN_POOL)
  FROM @SPECS
  SPECIFICATION_FILE = 'service.yaml'
  EXTERNAL_ACCESS_INTEGRATIONS = ($EXT_ACC_INT_NAME)
  QUERY_WAREHOUSE = $SERVICE_RUN_VWHS
  MIN_INSTANCES = 1
  MAX_INSTANCES = 1
;

--GRANT SERVICE ROLE IDENTIFIER($SERVICE_NAME)!IDENTIFIER($SERVICE_AXS_ROLE) TO ROLE IDENTIFIER($APP_ROLE_TYPE_01);
GRANT SERVICE ROLE APP_<% depname %>_SVC!APP_<% depname %>_AXSROLE TO ROLE IDENTIFIER($APP_ROLE_TYPE_01);

SHOW SERVICES;

-- wait for service provisioning to complete
CALL SYSTEM$WAIT(2, 'MINUTES');

-- check the status of service
CALL SYSTEM$GET_SERVICE_STATUS($SERVICE_NAME);

SHOW ENDPOINTS IN SERVICE IDENTIFIER($SERVICE_NAME);
SET app_url = (SELECT "ingress_url" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE "is_public" = true AND "ingress_url" like '%snowflakecomputing.app');
ALTER SCHEMA IF EXISTS IDENTIFIER($DEPLOY_SCHEMA) SET COMMENT = $app_url;
ALTER NOTEBOOK IF EXISTS IDENTIFIER($APP_NB_CONTROL) SET COMMENT = $app_url;
