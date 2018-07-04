object Pub: TPub
  OldCreateOrder = False
  Height = 339
  Width = 638
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=Wo$mXp2013;Persist Security Info=Tr' +
      'ue;User ID=MXPWOuser;Initial Catalog=MarineXProcurement;Data Sou' +
      'rce=sqlus2.mxp-intra.net\VOCSHIP'
    KeepConnection = False
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 40
    Top = 8
  end
  object Login: TADOQueryMX
    Connection = ADOConnection1
    EnableBCD = False
    Parameters = <
      item
        Name = 'DATE'
        DataType = ftDateTime
        Size = -1
        Value = Null
      end
      item
        Name = 'user'
        DataType = ftString
        Size = 10
        Value = Null
      end
      item
        Name = 'pin'
        DataType = ftString
        Size = 6
        Value = Null
      end
      item
        Name = 'org_unit_override'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'department'
        DataType = ftInteger
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE @DATE DATETIME = ISNULL(:DATE, GETDATE())'
      'DECLARE @user VARCHAR(10) = :user'
      'DECLARE @pin VARCHAR(6) = :pin'
      'DECLARE @org_unit_override INT = :org_unit_override'
      'DECLARE @department INT = :department'
      ''
      'SELECT '
      #9'tmpLogin.*'
      #9'--'
      #9', Org_Units.ORG_UNIT_NAME'
      #9'--'
      #9', Positions.POSITION_ID'
      #9', Positions.DEPARTMENT_ID'
      #9', Positions.POSITION_NAME'
      #9'--'#9
      
        #9', AccessRightsVesselStatusReport.USER_ACCESS_RIGHT_ID AS ACCESS' +
        '_RIGHTS_VESSEL_STAUS_REPORT_ID'
      
        #9', AccessRightsVesselStatusReport.USER_ACCESS_READ AS ACCESS_RIG' +
        'HTS_VESSEL_STAUS_REPORT_READ'
      
        #9', AccessRightsVesselStatusReport.USER_ACCESS_CREATE AS ACCESS_R' +
        'IGHTS_VESSEL_STAUS_REPORT_CREATE'
      
        #9', AccessRightsVesselStatusReport.USER_ACCESS_MODIFY AS ACCESS_R' +
        'IGHTS_VESSEL_STAUS_REPORT_MODIFY'
      #9'--'
      
        #9', AccessRightsWorkOrder.USER_ACCESS_RIGHT_ID AS ACCESS_RIGHTS_W' +
        'ORK_ORDER_ID'
      
        #9', AccessRightsWorkOrder.USER_ACCESS_READ AS ACCESS_RIGHTS_WORK_' +
        'ORDER_READ'
      
        #9', AccessRightsWorkOrder.USER_ACCESS_CREATE AS ACCESS_RIGHTS_WOR' +
        'K_ORDER_CREATE'
      
        #9'--, AccessRightsWorkOrder.USER_ACCESS_MODIFY AS ACCESS_RIGHTS_W' +
        'ORK_ORDER_MODIFY'
      #9'--'
      
        #9', AccessRightsWorkOrderAcknowledge.USER_ACCESS_MODIFY AS ACCESS' +
        '_RIGHTS_WORK_ORDER_MODIFY'
      #9'--'
      
        #9', AccessRightsCallSummaryGeneral.USER_ACCESS_CREATE AS ACCESS_R' +
        'IGHTS_CALL_SUMMARY_GENERAL_CREATE'
      
        #9', AccessRightsCallSummaryGeneral.USER_ACCESS_READ AS ACCESS_RIG' +
        'HTS_CALL_SUMMARY_GENERAL_READ'
      
        #9', AccessRightsCallSummaryGeneral.USER_ACCESS_MODIFY AS ACCESS_R' +
        'IGHTS_CALL_SUMMARY_GENERAL_MODIFY'
      
        #9', AccessRightsCallSummaryDeck.USER_ACCESS_READ AS ACCESS_RIGHTS' +
        '_CALL_SUMMARY_DECK_READ'
      
        #9', AccessRightsCallSummaryDeck.USER_ACCESS_MODIFY AS ACCESS_RIGH' +
        'TS_CALL_SUMMARY_DECK_MODIFY'
      #9'--'
      
        #9', ('#39','#39' + ISNULL(tmpTourCategoryAccess.TOUR_PROGRAM_CATEGORY_TYP' +
        'E_IDS, '#39#39') + '#39','#39') AS TOUR_PROGRAM_CATEGORY_TYPE_IDS'
      #9'--'
      #9', tmpOrgUnits.ASSIGNED_ORG_UNITS'
      #9', tmpCities.ASSIGNED_CITIES'
      #9', tmpTourCategories.ASSIGNED_TOUR_CATEGORIES'
      #9'--'
      'FROM ('
      #9'SELECT'
      #9#9#39'PERSON'#39' AS LOGIN_TYPE'
      #9#9', Persons.PERSON_ID'
      #9#9', Persons.PERSON_FIRST_NAME'
      #9#9', Persons.PERSON_LAST_NAME'
      #9#9', Persons.PERSON_ORG_UNIT_CODE'
      #9#9'--, Persons.PERSON_PIN_CODE AS PIN_CODE_JUST_FOR_TESTING'
      #9#9', CASE WHEN Persons.PERSON_PIN_CODE = @pin'
      
        #9#9#9'THEN SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('#39'MD5'#39', @pin))' +
        ', 3 ,32) ELSE null END AS PERSON_PIN_CODE'
      
        #9#9', CASE WHEN Persons.PERSON_PIN_CODE = @pin THEN 1 ELSE 0 END A' +
        'S PIN_CODE_CORRECT'
      
        #9#9', CASE WHEN (Persons.PERSON_ORG_UNIT_CODE = Persons.PERSON_PIN' +
        '_CODE)'
      #9#9#9'THEN 1 ELSE 0 END AS CHANGE_PIN_PROMPT'
      #9#9'--'
      #9#9', Person_Booking.PERSON_BOOKING_ID'
      #9#9', Person_Booking.USER_ID AS PERSON_USER_ID'
      #9#9', Person_Booking.ARRIVAL_DATE'
      #9#9', Person_Booking.DEPARTURE_DATE'
      #9#9'--'
      #9#9',  Person_Booking.POSITION_ID'
      #9#9'--'
      #9#9'--, UserRole.USER_ID'
      #9#9', Users.USER_ID'
      #9#9'--, UserRole.GUID AS USER_GUID'
      #9#9', Users.GUID AS USER_GUID'
      #9#9', UserRole.USER_ID AS USER_ROLE_ID'
      #9#9'--, UserRole.GUID AS USER_ROLE_GUID'
      #9#9', UserRole.USER_DB_NAME'
      #9#9', UserRole.USER_STATUS_ID'
      #9#9', UserRole.USER_FIRST_NAME'
      #9#9', UserRole.USER_LAST_NAME'
      #9#9', UserRole.USER_TOTAL_NAME'
      #9#9', UserRole.USER_LOGIN_CODE'
      #9#9', Person_Booking.ORG_UNIT_ID'
      #9#9'--'
      #9#9', UserRole.GUID AS USER_ROLE_GUID'
      #9#9'--'
      #9'FROM Person_Booking with(nolock)'
      
        #9'LEFT JOIN Users AS UserRole with(nolock) ON UserRole.USER_ID = ' +
        'Person_Booking.USER_ROLE_ID'
      #9#9'AND UserRole.REC_DELETED = 0'
      
        #9'LEFT JOIN Users with(nolock) on Person_Booking.USER_ID = Users.' +
        'USER_ID'
      #9#9'AND Users.REC_DELETED = 0'
      
        #9'INNER JOIN Persons with(nolock) ON Person_Booking.PERSON_ID = P' +
        'ersons.PERSON_ID'
      #9'WHERE Persons.PERSON_ORG_UNIT_CODE = @user'
      #9'AND Person_Booking.BOOKING_ARRIVAL_STATUS = 1'
      
        #9'AND CAST(@DATE AS DATE) BETWEEN Person_Booking.ARRIVAL_DATE AND' +
        ' Person_Booking.DEPARTURE_DATE'
      #9'AND Person_Booking.REC_DELETED = 0'
      ''
      #9'UNION'
      #9
      #9'SELECT'
      #9#9#39'USER'#39' AS LOGIN_TYPE'
      #9#9', NULL AS PERSON_ID'
      #9#9', Users.USER_FIRST_NAME AS PERSON_FIRST_NAME'
      #9#9', Users.USER_LAST_NAME AS PERSON_LAST_NAME'
      
        #9#9', CAST(Users.USER_LOGIN_CODE AS VARCHAR(10)) AS PERSON_ORG_UNI' +
        'T_CODE'
      #9#9'--, Users.USER_PIN_CODE AS PIN_CODE_JUST_FOR_TESTING'
      #9#9', CASE WHEN Users.USER_PIN_CODE = @pin'
      
        #9#9#9'THEN SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('#39'MD5'#39', @pin))' +
        ', 3 ,32) ELSE null END AS PERSON_PIN_CODE'
      
        #9#9', CASE WHEN Users.USER_PIN_CODE = @pin THEN 1 ELSE 0 END AS PI' +
        'N_CODE_CORRECT'
      #9#9', CASE WHEN (Users.USER_LOGIN_CODE = Users.USER_PIN_CODE)'
      #9#9#9'THEN 1 ELSE 0 END AS CHANGE_PIN_PROMPT'
      #9#9'--'
      #9#9', NULL AS PERSON_BOOKING_ID'
      #9#9', NULL AS PERSON_USER_ID'
      #9#9', NULL AS ARRIVAL_DATE'
      #9#9', NULL AS DEPARTURE_DATE'
      #9#9'--'
      #9#9', Users.POSITION_ID'
      #9#9'--'
      #9#9', Users.USER_ID'
      #9#9', Users.GUID AS USER_GUID'
      #9#9', Users.USER_ROLE_ID'
      #9#9'--, UserRole.GUID AS USER_ROLE_GUID'
      #9#9', Users.USER_DB_NAME'
      #9#9', Users.USER_STATUS_ID'
      #9#9', Users.USER_FIRST_NAME'
      #9#9', Users.USER_LAST_NAME'
      #9#9', Users.USER_TOTAL_NAME'
      #9#9', Users.USER_LOGIN_CODE'
      #9#9', Users.ORG_UNIT_ID'
      #9#9'--'
      #9#9', UserRole.GUID AS USER_ROLE_GUID'
      #9#9'--'
      #9'FROM Users with(nolock)'
      
        #9'LEFT JOIN Users as UserRole with(nolock) on UserRole.USER_ID = ' +
        'Users.USER_ROLE_ID'
      #9'WHERE Users.USER_LOGIN_CODE = @user'
      #9'AND Users.REC_DELETED = 0'
      ''
      ') AS tmpLogin'
      '--'
      
        'LEFT JOIN Config_Base_System with(nolock) ON Config_Base_System.' +
        'ORG_UNIT_ID = tmpLogin.ORG_UNIT_ID'
      
        'LEFT JOIN Org_Units on Org_Units.ORG_UNIT_ID = Config_Base_Syste' +
        'm.ORG_UNIT_ID'
      '--'
      
        'LEFT JOIN Positions with(nolock) ON Positions.POSITION_ID = tmpL' +
        'ogin.POSITION_ID'
      #9'AND Positions.ACTIVE = 1'
      #9'AND Positions.REC_DELETED = 0'
      
        #9'AND CAST(@DATE AS DATE) BETWEEN Positions.POSITION_VALID_FROM A' +
        'ND Positions.POSITION_VALID_TO'
      '--'
      
        'LEFT JOIN User_Access_Rights AS AccessRightsVesselStatusReport w' +
        'ith(nolock) ON AccessRightsVesselStatusReport.USER_ID = tmpLogin' +
        '.USER_ROLE_ID'
      
        #9'AND AccessRightsVesselStatusReport.USER_ACCESS_RIGHT_ITEM_ID = ' +
        '197 /* Vessel Status Report */'
      #9'AND AccessRightsVesselStatusReport.REC_DELETED = 0'
      #9
      
        'LEFT JOIN User_Access_Rights AS AccessRightsWorkOrder with(noloc' +
        'k) ON AccessRightsWorkOrder.USER_ID = tmpLogin.USER_ROLE_ID'
      
        #9'AND AccessRightsWorkOrder.USER_ACCESS_RIGHT_ITEM_ID = 821 /* Wo' +
        'rk order - General */'
      #9'AND AccessRightsWorkOrder.REC_DELETED = 0'
      #9
      
        'LEFT JOIN User_Access_Rights AS AccessRightsWorkOrderAcknowledge' +
        ' with(nolock) ON AccessRightsWorkOrderAcknowledge.USER_ID = tmpL' +
        'ogin.USER_ROLE_ID'
      
        #9'AND AccessRightsWorkOrderAcknowledge.USER_ACCESS_RIGHT_ITEM_ID ' +
        '= 823 /* Work order - Acknowledge */'
      #9'AND AccessRightsWorkOrderAcknowledge.REC_DELETED = 0'
      #9
      
        'LEFT JOIN User_Access_Rights AS AccessRightsCallSummaryDeck with' +
        '(nolock) ON AccessRightsCallSummaryDeck.USER_ID = tmpLogin.USER_' +
        'ROLE_ID'
      
        #9'AND AccessRightsCallSummaryDeck.USER_ACCESS_RIGHT_ITEM_ID = 185' +
        ' /* Call Summary Deck Dept */'
      #9'AND AccessRightsCallSummaryDeck.REC_DELETED = 0'
      #9
      
        'LEFT JOIN User_Access_Rights AS AccessRightsCallSummaryGeneral w' +
        'ith(nolock) ON AccessRightsCallSummaryGeneral.USER_ID = tmpLogin' +
        '.USER_ROLE_ID'
      
        #9'AND AccessRightsCallSummaryGeneral.USER_ACCESS_RIGHT_ITEM_ID = ' +
        '184 /* Call Summary General */'
      #9'AND AccessRightsCallSummaryGeneral.REC_DELETED = 0'
      '--'
      'OUTER APPLY ('
      #9'SELECT STUFF('
      #9'('
      #9#9'SELECT '#39','#39' +   '
      #9#9#9'CASE'
      #9#9#9#9'WHEN USER_ACCESS_RIGHT_ITEM_ID = 606 THEN '#39'1,3'#39' '
      #9#9#9#9'WHEN USER_ACCESS_RIGHT_ITEM_ID = 579 THEN '#39'2'#39
      #9#9#9#9'WHEN USER_ACCESS_RIGHT_ITEM_ID = 607 THEN '#39'4'#39' '
      #9#9#9#9'WHEN USER_ACCESS_RIGHT_ITEM_ID = 608 THEN '#39'5'#39' '
      #9#9#9#9'ELSE NULL'
      #9#9#9'END '
      #9#9'FROM Users WITH(NOLOCK)'
      
        #9#9'LEFT JOIN User_Access_Rights WITH(NOLOCK) ON User_Access_Right' +
        's.USER_ID = ISNULL(Users.USER_ROLE_ID, Users.USER_ID)'
      #9#9#9'AND User_Access_Rights.REC_DELETED = 0'
      
        #9#9#9'AND User_Access_Rights.USER_ACCESS_RIGHT_ITEM_ID IN (579, 606' +
        ', 607, 608)'
      #9#9#9'AND User_Access_Rights.USER_ACCESS_READ = 1'
      #9#9'WHERE Users.USER_ID = tmpLogin.USER_ID'
      #9#9'FOR XML PATH('#39#39')'
      #9'), 1, 1, '#39#39') AS TOUR_PROGRAM_CATEGORY_TYPE_IDS'
      ') AS tmpTourCategoryAccess'
      '--'
      'OUTER APPLY ('
      #9'SELECT STUFF('
      #9'('
      
        #9#9'SELECT /*'#39';'#39' + CAST(User_Org_Units.ORG_UNIT_ID AS VARCHAR(10))' +
        ' +*/ '#39'|'#39' + Org_Units.ORG_UNIT_NAME'
      #9#9'FROM User_Org_Units WITH(NOLOCK) '
      
        #9#9'INNER JOIN Org_Units WITH(NOLOCK) ON Org_Units.ORG_UNIT_ID = U' +
        'ser_Org_Units.ORG_UNIT_ID'
      #9#9'WHERE User_Org_Units.USER_ID = tmpLogin.USER_ID'
      #9#9'AND User_Org_Units.REC_DELETED = 0'
      #9#9'ORDER BY Org_Units.ORG_UNIT_NAME'
      #9#9'FOR XML PATH('#39#39')'
      #9'), 1, 1, '#39#39') AS ASSIGNED_ORG_UNITS'
      ') tmpOrgUnits'
      'OUTER APPLY ('
      #9'SELECT STUFF('
      #9'('
      
        #9#9'SELECT /*'#39';'#39' + CAST(User_Cities.CITY_ID AS VARCHAR(10)) +*/ '#39'|' +
        #39' + Cities.CITY_NAME'
      #9#9'FROM User_Cities WITH(NOLOCK)'
      
        #9#9'INNER JOIN Cities WITH(NOLOCK) ON Cities.CITY_ID = User_Cities' +
        '.CITY_ID'
      #9#9'WHERE USER_ID = tmpLogin.USER_ID'
      #9#9'AND TOUR_COUNT_ACCESS = 1'
      #9#9'AND REC_DELETED = 0 '
      #9#9'ORDER BY Cities.CITY_NAME'
      #9#9'FOR XML PATH('#39#39')'
      #9'), 1, 1, '#39#39') AS ASSIGNED_CITIES'
      ') tmpCities'
      'OUTER APPLY ('
      #9'SELECT STUFF('
      #9'('
      
        #9#9'SELECT '#39'|'#39' + VUser_Access_Right_Items.USER_ACCESS_RIGHT_ITEM_N' +
        'AME + CASE WHEN User_Access_Rights.USER_ACCESS_MODIFY = 1 THEN '#39 +
        #39' ELSE '#39' (read-only)'#39' END '
      #9#9'FROM Users WITH(NOLOCK)'
      
        #9#9'INNER JOIN User_Access_Rights WITH(NOLOCK) ON User_Access_Righ' +
        'ts.USER_ID = ISNULL(Users.USER_ROLE_ID, Users.USER_ID)'
      #9#9#9'AND User_Access_Rights.REC_DELETED = 0'
      
        #9#9#9'AND User_Access_Rights.USER_ACCESS_RIGHT_ITEM_ID IN (579, 606' +
        ', 607, 608)'
      #9#9#9'AND User_Access_Rights.USER_ACCESS_READ = 1'
      
        #9#9'INNER JOIN VUser_Access_Right_Items WITH(NOLOCK) ON VUser_Acce' +
        'ss_Right_Items.USER_ACCESS_RIGHT_ITEM_ID = User_Access_Rights.US' +
        'ER_ACCESS_RIGHT_ITEM_ID'
      #9#9'WHERE Users.USER_ID = tmpLogin.USER_ID'
      #9#9'ORDER BY VUser_Access_Right_Items.USER_ACCESS_RIGHT_ITEM_ID'
      #9#9'FOR XML PATH('#39#39')'
      #9'), 1, 1, '#39#39') AS ASSIGNED_TOUR_CATEGORIES'
      ') AS tmpTourCategories'
      ''
      
        'WHERE (@department IS NULL OR @department = Positions.DEPARTMENT' +
        '_ID)'
      'AND ('
      
        #9'(@org_unit_override IS NULL AND  tmpLogin.ORG_UNIT_ID = Config_' +
        'Base_System.ORG_UNIT_ID)'
      #9'OR tmpLogin.ORG_UNIT_ID = @org_unit_override'
      #9'OR tmpLogin.ORG_UNIT_ID = 1'
      ')'
      ''
      'ORDER BY '
      #9'tmpLogin.PIN_CODE_CORRECT DESC'
      #9', tmpLogin.ORG_UNIT_ID'
      #9', tmpLogin.LOGIN_TYPE DESC')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.EnableBCD = False
    InsertQuery.Parameters = <>
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.EnableBCD = False
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <
      item
        Name = 'USER_ID'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'PERSON_ID'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'LOGIN_CODE'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'PIN_CODE'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 100
        Value = Null
      end
      item
        Name = 'NEW_PIN_CODE'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 6
        Value = Null
      end>
    UpdateQuery.SQL.Strings = (
      'DECLARE @USER_ID INT = :USER_ID'
      'DECLARE @PERSON_ID INT = :PERSON_ID'
      'DECLARE @LOGIN_CODE INT = :LOGIN_CODE'
      'DECLARE @PIN_CODE VARCHAR(MAX) = :PIN_CODE'
      'DECLARE @NEW_PIN_CODE VARCHAR(6) = :NEW_PIN_CODE'
      ''
      'IF @USER_ID IS NOT NULL'
      'BEGIN'
      #9'UPDATE Users SET '
      #9'USER_PIN_CODE = CAST(@NEW_PIN_CODE AS INT)'
      #9'WHERE USER_ID = @USER_ID'
      #9'AND USER_LOGIN_CODE = @LOGIN_CODE'
      
        #9'AND SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('#39'MD5'#39', CAST(USER' +
        '_PIN_CODE AS VARCHAR(MAX)))), 3 ,32) = @PIN_CODE'
      'END'
      'ELSE IF @PERSON_ID IS NOT NULL '
      'BEGIN'
      #9'UPDATE Persons SET '
      #9'PERSON_PIN_CODE = @NEW_PIN_CODE'
      #9'WHERE PERSON_ID = @PERSON_ID '
      #9'AND PERSON_ORG_UNIT_CODE = @LOGIN_CODE'
      
        #9'AND SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('#39'MD5'#39', PERSON_PI' +
        'N_CODE)), 3 ,32) = @PIN_CODE'
      'END')
    Left = 40
    Top = 104
  end
  object Info: TADOQueryMX
    Connection = ADOConnection1
    EnableBCD = False
    Parameters = <
      item
        Name = 'DATE'
        Attributes = [paNullable]
        DataType = ftDateTime
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE @DATE datetime = CAST(ISNULL(:DATE, GETDATE()) AS DATE)'
      ''
      'SELECT TOP 1'
      #9'GETUTCDATE() as UTCDATE'
      #9', GETDATE() as '#39'DATE'#39
      #9', Org_Units.ORG_UNIT_ID'
      #9', Org_Units.ORG_UNIT_NAME '
      #9', Cruise.CRUISE_NUMBER'
      #9', Cruise.START_DATE AS CRUISE_START_DATE'
      #9', Cruise.END_DATE AS CRUISE_END_DATE '
      #9', Org_Companies.ORG_COMPANY_NAME'
      #9', Org_Companies.ORG_COMPANY_ABBREVIATION'
      #9', Org_Companies.MXP_CLIENT_ID'
      'FROM Org_Units'
      
        'INNER JOIN VSys_Org_Unit ON VSys_Org_Unit.ORG_UNIT_ID = Org_Unit' +
        's.ORG_UNIT_ID'
      
        'LEFT OUTER JOIN Cruise WITH(NOLOCK) ON Org_Units.ORG_UNIT_ID = C' +
        'ruise.ORG_UNIT_ID '
      #9'AND Cruise.CRUISE_TYPE = '#39'C'#39
      #9'AND Cruise.CRUISE_PLANNING_STATUS = 4 '
      #9'AND Cruise.DELETED = 0 '
      #9'AND Cruise.ACTIVE = 1 '
      #9'AND Cruise.ALTERNATE_CRUISE = 0'
      #9'AND @DATE BETWEEN Cruise.START_DATE AND Cruise.END_DATE'
      
        'LEFT OUTER JOIN Org_Companies WITH(NOLOCK) ON Org_Companies.ORG_' +
        'COMPANY_ID = VSys_Org_Unit.ORG_COMPANY_ID')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.EnableBCD = False
    InsertQuery.Parameters = <>
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.EnableBCD = False
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 40
    Top = 56
  end
  object UserAccessRights: TADOQueryMX
    Connection = ADOConnection1
    EnableBCD = False
    Parameters = <
      item
        Name = 'USER_ROLE_GUID'
        DataType = ftGuid
        Size = -1
        Value = Null
      end
      item
        Name = 'ONLY_ENABLED'
        DataType = ftBoolean
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE @USER_ROLE_GUID UNIQUEIDENTIFIER = :USER_ROLE_GUID'
      'DECLARE @ONLY_ENABLED BIT = ISNULL(:ONLY_ENABLED, 0)'
      ''
      'DECLARE @USER_ID INT'
      ''
      'SELECT @USER_ID = USER_ID '
      'FROM Users WITH(NOLOCK)'
      'WHERE GUID = @USER_ROLE_GUID'
      ''
      'IF @USER_ID IS NULL'
      'BEGIN'
      
        #9'SELECT '#39'User was role not found'#39' AS ERR_MSG, '#39'user-role-not-fou' +
        'nd'#39' AS ERR_CODE'
      'END'
      'ELSE '
      'BEGIN'
      #9'SELECT '
      #9#9'User_Access_Rights.USER_ACCESS_RIGHT_ITEM_ID AS [ID]'
      #9#9', VUser_Access_Right_Items.SYS_LOOKUP_ITEM_NAME AS [CATEGORY]'
      
        #9#9', VUser_Access_Right_Items.User_Access_Right_Item_Name AS [ITE' +
        'M]'
      #9#9', LIContactCategory.LOOKUP_ITEM_NAME AS [CONTACT_CATEGORY]'
      #9#9', User_Access_Rights.ORG_UNIT_ID AS [ORG_UNIT_ID]'
      #9#9', User_Access_Rights.USER_ACCESS_READ AS [READ]'
      #9#9', User_Access_Rights.USER_ACCESS_CREATE AS [CREATE]'
      #9#9', User_Access_Rights.USER_ACCESS_MODIFY AS [MODIFY]'
      #9#9', User_Access_Rights.USER_ACCESS_DELETE AS [DELETE]'
      
        #9#9', User_Access_Rights.USER_ACCESS_ACTIVATE AS [USER_ACCESS_ACTI' +
        'VATE]'
      #9'FROM User_Access_Rights WITH(NOLOCK) '
      
        #9'INNER JOIN VUser_Access_Right_Items WITH(NOLOCK) ON User_Access' +
        '_Rights.USER_ACCESS_RIGHT_ITEM_ID = VUser_Access_Right_Items.USE' +
        'R_ACCESS_RIGHT_ITEM_ID'
      
        #9'LEFT JOIN Lookup_Items AS LIContactCategory WITH(NOLOCK) ON Use' +
        'r_Access_Rights.CONTACT_CATEGORY_ID = LIContactCategory.LOOKUP_I' +
        'TEM_ID'
      
        #9#9'AND LIContactCategory.LOOKUP_SUB_CATEGORY_ID = 5 /* Contact Ca' +
        'tegory */'
      #9'WHERE User_Access_Rights.REC_DELETED = 0'
      #9'AND User_Access_Rights.USER_ID = @USER_ID'
      #9'AND ('
      #9#9'@ONLY_ENABLED = 0'
      #9#9'OR ('
      #9#9#9'User_Access_Rights.USER_ACCESS_READ = 1'
      #9#9#9'OR User_Access_Rights.USER_ACCESS_CREATE = 1'
      #9#9#9'OR User_Access_Rights.USER_ACCESS_CREATE = 1'
      #9#9#9'OR User_Access_Rights.USER_ACCESS_DELETE = 1'
      #9#9')'
      #9')'
      #9'ORDER BY [CATEGORY], [ITEM], [ORG_UNIT_ID]'
      'END')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.EnableBCD = False
    InsertQuery.Parameters = <>
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.EnableBCD = False
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 40
    Top = 152
  end
  object _Library: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <>
    InsertQuery.Connection = ADOConnection1
    InsertQuery.Parameters = <>
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 576
    Top = 8
  end
  object Programs: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <>
    SQL.Strings = (
      'SELECT'
      #9'programs.GUID AS '#39'id'#39
      #9'--'
      #9', programs.TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', programs.TRAINING_PROGRAM_NAME AS '#39'name'#39
      #9', programs.TRAINING_PROGRAM_CATEGORY_ID AS '#39'categoryId'#39
      #9', programs.TRAINING_PROGRAM_DESCRIPTION AS '#39'description'#39
      #9', programs.TRAINING_PROGRAM_VALID_FROM AS '#39'validFrom'#39
      #9', programs.TRAINING_PROGRAM_VALID_TO AS '#39'validTo'#39
      #9', programs.MAXIMUM_COMPLETION_TIME AS '#39'completionTime'#39
      
        #9', programs.MAX_ATTEMPTS_TRAINING_MODE AS '#39'maxAttemptsTrainingMo' +
        'de'#39
      #9', programs.MAX_ATTEMPTS_SCORE_MODE AS '#39'maxAttemptsScoreMode'#39
      #9', programs.PASS_SCORE AS '#39'passScore'#39
      
        #9', programs.CERTIFICATE_REPORT_FILE_NAME AS '#39'certificateFileName' +
        #39
      #9', programs.ACTIVE AS '#39'active'#39
      #9', programs.CREATED_BY_ID AS '#39'createdById'#39
      #9', programs.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', programs.CREATED AS '#39'created'#39
      #9', programs.LAST_CHANGED AS '#39'lastChanges'#39
      #9', programs.CHANGED AS '#39'changed'#39
      #9', programs.LAST_CHANGE_LOG_ID AS '#39'lastChangeLogId'#39
      'FROM Training_Programs AS programs'
      'WHERE programs.REC_DELETED = 0')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.Parameters = <
      item
        Name = 'id'
        DataType = ftGuid
        Size = -1
        Value = Null
      end
      item
        Name = 'programId'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'name'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 300
        Value = Null
      end
      item
        Name = 'categoryId'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'description'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 8000
        Value = Null
      end
      item
        Name = 'validFrom'
        DataType = ftDateTime
        Size = -1
        Value = Null
      end
      item
        Name = 'validTo'
        DataType = ftDateTime
        Size = -1
        Value = Null
      end
      item
        Name = 'completionTime'
        DataType = ftFloat
        Size = -1
        Value = Null
      end
      item
        Name = 'maxAttemptsTrainingMode'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'maxAttemptsScoreMode'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'passScore'
        DataType = ftFloat
        Size = -1
        Value = Null
      end
      item
        Name = 'certificateFileName'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 200
        Value = Null
      end
      item
        Name = 'active'
        DataType = ftBoolean
        Size = -1
        Value = Null
      end>
    InsertQuery.SQL.Strings = (
      'DECLARE @id UNIQUEIDENTIFIER = :id'
      'DECLARE @programId INT = :programId'
      'DECLARE @name NVARCHAR(300) = :name'
      'DECLARE @categoryId INT = :categoryId'
      'DECLARE @description NVARCHAR(MAX)= :description'
      'DECLARE @validFrom DATETIME = :validFrom'
      'DECLARE @validTo DATETIME = :validTo'
      'DECLARE @completionTime NUMERIC(18,2) = :completionTime'
      'DECLARE @maxAttemptsTrainingMode INT = :maxAttemptsTrainingMode'
      'DECLARE @maxAttemptsScoreMode INT = :maxAttemptsScoreMode'
      'DECLARE @passScore NUMERIC(18,2) = :passScore'
      
        'DECLARE @certificateFileName NVARCHAR(200) = :certificateFileNam' +
        'e'
      'DECLARE @active BIT = :active'
      ''
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @id)'
      ''
      'IF @programId IS NULL'
      'BEGIN'
      #9'INSERT INTO Training_Programs ('
      #9#9'GUID'
      #9#9'--, TRAINING_PROGRAM_ID'
      #9#9', TRAINING_PROGRAM_NAME'
      #9#9', TRAINING_PROGRAM_CATEGORY_ID'
      #9#9', TRAINING_PROGRAM_DESCRIPTION'
      #9#9', TRAINING_PROGRAM_VALID_FROM'
      #9#9', TRAINING_PROGRAM_VALID_TO'
      #9#9', MAXIMUM_COMPLETION_TIME'
      #9#9', MAX_ATTEMPTS_TRAINING_MODE'
      #9#9', MAX_ATTEMPTS_SCORE_MODE'
      #9#9', PASS_SCORE'
      #9#9', CERTIFICATE_REPORT_FILE_NAME'
      #9#9', ACTIVE'
      #9')'
      #9'VALUES ('
      #9#9'@id'
      #9#9'--, @programId'
      #9#9', @name'
      #9#9', @categoryId'
      #9#9', @description'
      #9#9', @validFrom'
      #9#9', @validTo'
      #9#9', @completionTime'
      #9#9', @maxAttemptsTrainingMode'
      #9#9', @maxAttemptsScoreMode'
      #9#9', @passScore'
      #9#9', @certificateFileName'
      #9#9', @active'
      #9')'
      
        #9'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Prog' +
        'rams WHERE ROW_COUNTER = SCOPE_IDENTITY())'
      'END'
      'ELSE'
      'BEGIN'
      #9'UPDATE Training_Programs SET'
      #9#9'TRAINING_PROGRAM_NAME = ISNULL(@name, TRAINING_PROGRAM_NAME)'
      
        #9#9', TRAINING_PROGRAM_CATEGORY_ID = ISNULL(@categoryId, TRAINING_' +
        'PROGRAM_CATEGORY_ID)'
      
        #9#9', TRAINING_PROGRAM_DESCRIPTION = ISNULL(@description, TRAINING' +
        '_PROGRAM_DESCRIPTION)'
      
        #9#9', TRAINING_PROGRAM_VALID_FROM = ISNULL(@validFrom, TRAINING_PR' +
        'OGRAM_VALID_FROM)'
      
        #9#9', TRAINING_PROGRAM_VALID_TO = ISNULL(@validTo, TRAINING_PROGRA' +
        'M_VALID_TO)'
      
        #9#9', MAXIMUM_COMPLETION_TIME = ISNULL(@completionTime, MAXIMUM_CO' +
        'MPLETION_TIME)'
      
        #9#9', MAX_ATTEMPTS_TRAINING_MODE = ISNULL(@maxAttemptsTrainingMode' +
        ', MAX_ATTEMPTS_TRAINING_MODE)'
      
        #9#9', MAX_ATTEMPTS_SCORE_MODE = ISNULL(@maxAttemptsScoreMode, MAX_' +
        'ATTEMPTS_SCORE_MODE)'
      #9#9', PASS_SCORE = ISNULL(@passScore, PASS_SCORE)'
      
        #9#9', CERTIFICATE_REPORT_FILE_NAME = ISNULL(@certificateFileName, ' +
        'CERTIFICATE_REPORT_FILE_NAME)'
      #9#9', ACTIVE = ISNULL(@active, ACTIVE)'
      #9'WHERE TRAINING_PROGRAM_ID = @programId'
      'END'
      ''
      'SELECT'
      #9'programs.GUID AS '#39'id'#39
      #9', programs.TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', programs.TRAINING_PROGRAM_NAME AS '#39'name'#39
      #9', programs.TRAINING_PROGRAM_CATEGORY_ID AS '#39'categoryId'#39
      #9', programs.TRAINING_PROGRAM_DESCRIPTION AS '#39'description'#39
      #9', programs.TRAINING_PROGRAM_VALID_FROM AS '#39'validFrom'#39
      #9', programs.TRAINING_PROGRAM_VALID_TO AS '#39'validTo'#39
      #9', programs.MAXIMUM_COMPLETION_TIME AS '#39'completionTime'#39
      
        #9', programs.MAX_ATTEMPTS_TRAINING_MODE AS '#39'maxAttemptsTrainingMo' +
        'de'#39
      #9', programs.MAX_ATTEMPTS_SCORE_MODE AS '#39'maxAttemptsScoreMode'#39
      #9', programs.PASS_SCORE AS '#39'passScore'#39
      
        #9', programs.CERTIFICATE_REPORT_FILE_NAME AS '#39'certificateFileName' +
        #39
      #9', programs.ACTIVE AS '#39'active'#39
      #9', programs.CREATED_BY_ID AS '#39'createdById'#39
      #9', programs.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', programs.CREATED AS '#39'created'#39
      #9', programs.LAST_CHANGED AS '#39'lastChanges'#39
      #9', programs.CHANGED AS '#39'changed'#39
      #9', programs.LAST_CHANGE_LOG_ID AS '#39'lastChangeLogId'#39
      'FROM Training_Programs AS programs'
      'WHERE programs.TRAINING_PROGRAM_ID = @programId')
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <
      item
        Name = 'id'
        DataType = ftGuid
        NumericScale = 255
        Precision = 255
        Size = 16
        Value = Null
      end>
    DeleteQuery.SQL.Strings = (
      'UPDATE Training_Programs '
      'SET REC_DELETED = 1'
      'WHERE GUID = :id')
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 216
    Top = 8
  end
end
