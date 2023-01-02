-- get apex user, higher performance than v function
SELECT sys_context('APEX$SESSION','APP_USER') FROM DUAL;
