object Pub: TPub
  OldCreateOrder = False
  Height = 342
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
  object Pages: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <
      item
        Name = 'programId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end>
    SQL.Strings = (
      
        'DECLARE @programId INT = NULL -- gets set later -- get only page' +
        's for specific programId'
      
        'DECLARE @programGuid NVARCHAR(38) = :programId -- guid of progra' +
        'm this slide belongs to'
      ''
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @programGuid) -- get program id from guid'
      ''
      'SELECT '#9'pages.ACTIVE AS '#39'active'#39
      #9', pages.CAN_NAVIGATE_TO_NEXT_PAGE AS '#39'canNextPage'#39
      #9', pages.CAN_NAVIGATE_TO_PREVIOUS_PAGE AS '#39'canPrevPage'#39
      #9', pages.CHANGED AS '#39'changed'#39
      #9', pages.CREATED AS '#39'created'#39
      #9', pages.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', pages.CREATED_BY_ID AS '#39'createdById'#39
      #9', pages.GUID AS '#39'id'#39
      #9', pages.LAST_CHANGED AS '#39'lastChanged'#39
      #9', pages.LAST_CHANGE_LOG_ID AS '#39'lastChangedLog'#39
      #9', pages.MAXIMUM_COMPLETION_TIME AS '#39'completionTime'#39
      #9', pages.MINIMUM_REVIEW_TIME AS '#39'reviewTime'#39
      #9', pages.REC_DELETED AS '#39'deleted'#39
      #9', pages.ROW_COUNTER AS '#39'rowCounter'#39
      #9'--, pages.TRAINING_PROGRAM_ID AS '#39'programId'#39
      
        #9', @programGuid AS '#39'programId'#39' -- TODO - i am returning guid bac' +
        'k'
      #9
      #9', pages.TRAINING_PROGRAM_PAGE_CATEGORY_ID AS '#39'categoryId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_CONTENT AS '#39'content'#39
      #9', pages.TRAINING_PROGRAM_PAGE_ID AS '#39'pageId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_MULTI_SELECT AS '#39'multiSelect'#39
      #9', pages.TRAINING_PROGRAM_PAGE_NAME AS '#39'title'#39
      ''
      #9', (   '
      #9'-- todo - inefficient '
      #9'CASE WHEN '
      
        #9'(SELECT GUID FROM Training_Program_Pages WHERE TRAINING_PROGRAM' +
        '_PAGE_ID = pages.TRAINING_PROGRAM_PAGE_PARENT_ID)'
      #9'IS NULL THEN '
      #9'NULL'
      #9'ELSE '
      #9'CONCAT('#39'{'#39
      
        #9', CAST((SELECT GUID FROM Training_Program_Pages WHERE TRAINING_' +
        'PROGRAM_PAGE_ID = pages.TRAINING_PROGRAM_PAGE_PARENT_ID) AS char' +
        '(36))'
      #9', '#39'}'#39
      #9')'
      #9
      #9'END'
      #9#9') AS '#39'parentId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SCORE_METHOD AS '#39'scoreMethod'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SEQUENCE AS '#39'sequence'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SOUND AS '#39'sound'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SOUND_URL AS '#39'soundUrl'#39
      #9', pages.TRAINING_PROGRAM_PAGE_TEMPLATE_ID AS '#39'templateId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_VIDEO AS '#39'video'#39
      #9', pages.TRAINING_PROGRAM_PAGE_VIDEO_URL AS '#39'videoUrl'#39
      ''
      ''
      #9'-- below are custom arguments to give to tree'
      #9' , 1 AS '#39'expanded'#39
      ''
      #9' ,(CASE WHEN '
      
        #9#9'(SELECT COUNT(*) AS numChildren FROM Training_Program_Pages AS' +
        ' CurrentPage'
      #9#9'INNER JOIN Training_Program_Pages  AS ParentPage '
      
        #9#9'ON (CurrentPage.TRAINING_PROGRAM_PAGE_PARENT_ID = ParentPage.T' +
        'RAINING_PROGRAM_PAGE_ID)'
      
        #9#9'WHERE ParentPage.TRAINING_PROGRAM_PAGE_ID = pages.TRAINING_PRO' +
        'GRAM_PAGE_ID'
      #9#9') > 0  -- if numChildren > 0 -> leaf = False else leaf = True'
      #9#9'THEN '
      #9#9'0'
      #9#9'ELSE '
      #9#9'1 '
      #9#9'END'
      #9#9') AS '#39'leaf'#39
      ''
      ''
      ''
      ''
      #9#9
      #9#9',(CASE WHEN '
      
        #9#9'(SELECT COUNT(*) AS numChildren FROM Training_Program_Pages AS' +
        ' CurrentPage'
      #9#9'INNER JOIN Training_Program_Pages  AS ParentPage '
      
        #9#9'ON (CurrentPage.TRAINING_PROGRAM_PAGE_PARENT_ID = ParentPage.T' +
        'RAINING_PROGRAM_PAGE_ID)'
      
        #9#9'WHERE ParentPage.TRAINING_PROGRAM_PAGE_ID = pages.TRAINING_PRO' +
        'GRAM_PAGE_ID'
      
        #9#9') = 0  -- if numChildren = 0 -> set variable children as empty' +
        ' array'
      #9#9'THEN '
      #9#9#39'{[]}'#39' --todo return empty array'
      #9#9'END'
      #9#9') AS '#39'children'#39
      ''
      ''
      #9#9',1 AS '#39'loaded'#39
      ''
      'FROM Training_Program_Pages AS pages'
      'WHERE pages.REC_DELETED = 0'
      'AND pages.TRAINING_PROGRAM_ID = @programId')
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
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'parentId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'title'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 200
        Value = Null
      end
      item
        Name = 'sequence'
        DataType = ftLargeint
        Size = -1
        Value = Null
      end
      item
        Name = 'categoryId'
        DataType = ftSmallint
        Size = -1
        Value = Null
      end
      item
        Name = 'content'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 8000
        Value = Null
      end
      item
        Name = 'multiSelect'
        DataType = ftBoolean
        Size = -1
        Value = Null
      end
      item
        Name = 'scoreMethod'
        DataType = ftFixedChar
        Size = -1
        Value = Null
      end>
    InsertQuery.SQL.Strings = (
      'DECLARE @pageId INT = NULL -- gets set later'
      
        'DECLARE @pageGuid UNIQUEIDENTIFIER = :id -- guid of this section' +
        '/slide'
      'DECLARE @programId INT = NULL -- gets set later'
      
        'DECLARE @programGuid NVARCHAR(38) = :programId -- guid of progra' +
        'm this slide belongs to'
      'DECLARE @parentId INT = NULL -- gets set later'
      
        'DECLARE @parentIdGuid NVARCHAR(38) = :parentId -- guid of parent' +
        ' (this should be varchar because of string "root" which cannot b' +
        'e converted to uniqueidentifier)'
      'DECLARE @name NVARCHAR(200) = :title'
      'DECLARE @sequence NUMERIC(18,0) = :sequence'
      'DECLARE @categoryId INT = :categoryId'
      'DECLARE @templateId INT = NULL'
      'DECLARE @content NVARCHAR(MAX) = :content'
      'DECLARE @reviewTime NUMERIC(18,2) = NULL'
      'DECLARE @completionTime NUMERIC(18,2) = NULL'
      'DECLARE @multiSelect BIT = :multiSelect'
      'DECLARE @scoreMethod VARCHAR(1) = :scoreMethod'
      
        'DECLARE @sound VARBINARY(MAX) = NULL -- todo - this is written i' +
        'n database as '#39'image'#39' but local variable image is not allowed'
      'DECLARE @soundUrl NVARCHAR(500) = NULL'
      
        'DECLARE @video VARBINARY(MAX) = NULL -- todo - this is written i' +
        'n database as '#39'image'#39' but local variable image is not allowed'
      'DECLARE @videoUrl NVARCHAR(500) = NULL'
      'DECLARE @canNextPage BIT = NULL'
      'DECLARE @canPrevPage BIT = NULL'
      'DECLARE @active BIT = 1'
      'DECLARE @deleted BIT = 0'
      'DECLARE @createdAtId INT = NULL'
      'DECLARE @createdById INT = NULL'
      'DECLARE @created DATETIME = GETDATE()'
      'DECLARE @lastChanged DATETIME = GETDATE()'
      'DECLARE @changed CHAR(1) = 0'
      'DECLARE @lastChangedLog BIGINT = NULL'
      ''
      
        'SET @pageId = (SELECT TRAINING_PROGRAM_PAGE_ID FROM Training_Pro' +
        'gram_Pages WHERE GUID = @pageGuid) -- get page id from guid'
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @programGuid) -- get program id from guid'
      ''
      '-- get parent id from guid'
      'BEGIN TRY  '
      
        '    SET @parentId = (SELECT TRAINING_PROGRAM_PAGE_ID FROM Traini' +
        'ng_Program_Pages WHERE GUID = @parentIdGuid) '
      'END TRY  '
      'BEGIN CATCH  '
      
        #9'-- catch if there is conversion error - "root" cannot be conver' +
        'ted into unique identifier'
      
        '    SET @parentId = -1 -- TODO - root element sets -1 but it sho' +
        'uld be null - but field TRAINING_PROGRAM_PAGE_PARENT_ID cannot b' +
        'e null as of 2018-07-12'
      #9'--SET @parentId = NULL'
      'END CATCH'
      ''
      
        '-- set content - it may be empty if we created slide and not sec' +
        'tion'
      ''
      ''
      '-- set parentId'
      ''
      'IF @pageId IS NULL'
      'BEGIN'
      
        #9'SET @content = ( CASE WHEN @content IS NULL THEN '#39#39' ELSE @conte' +
        'nt END ) -- TODO - inefficient - slide may have empty content bu' +
        't empty content is not allowed'
      #9'SET @active = 1'
      #9'SET @deleted = 0'
      #9'SET @created = GETDATE()'
      #9'SET @lastChanged = GETDATE()'
      #9'SET @changed = GETDATE()'
      ''
      #9'INSERT INTO Training_Program_Pages ('
      #9#9'GUID'
      #9#9'--, TRAINING_PROGRAM_PAGE_ID'
      #9#9', TRAINING_PROGRAM_ID'
      #9#9', TRAINING_PROGRAM_PAGE_PARENT_ID'
      #9#9', TRAINING_PROGRAM_PAGE_NAME'
      #9#9', TRAINING_PROGRAM_PAGE_SEQUENCE'
      #9#9', TRAINING_PROGRAM_PAGE_CATEGORY_ID'
      #9#9', TRAINING_PROGRAM_PAGE_TEMPLATE_ID'
      #9#9', TRAINING_PROGRAM_PAGE_CONTENT'
      #9#9', MINIMUM_REVIEW_TIME'
      #9#9', MAXIMUM_COMPLETION_TIME'
      #9#9', TRAINING_PROGRAM_PAGE_MULTI_SELECT'
      #9#9', TRAINING_PROGRAM_PAGE_SCORE_METHOD'
      #9#9', TRAINING_PROGRAM_PAGE_SOUND'
      #9#9', TRAINING_PROGRAM_PAGE_SOUND_URL'
      #9#9', TRAINING_PROGRAM_PAGE_VIDEO'
      #9#9', TRAINING_PROGRAM_PAGE_VIDEO_URL'
      #9#9', CAN_NAVIGATE_TO_NEXT_PAGE'
      #9#9', CAN_NAVIGATE_TO_PREVIOUS_PAGE'
      #9#9', ACTIVE'
      #9#9', REC_DELETED'
      #9#9', CREATED_AT_ID'
      #9#9', CREATED_BY_ID'
      #9#9', CREATED'
      #9#9', LAST_CHANGED'
      #9#9', CHANGED'
      #9#9', LAST_CHANGE_LOG_ID'
      #9')'
      #9'VALUES ('
      #9#9'@pageGuid'
      #9#9'--, @pageId'
      #9#9', @programId '
      #9#9', @parentId'
      #9#9', @name'
      #9#9', @sequence'
      #9#9', @categoryId'
      #9#9', @templateId'
      #9#9', @content'
      #9#9', @reviewTime'
      #9#9', @completionTime'
      #9#9', @multiSelect'
      #9#9', @scoreMethod'
      #9#9', @sound'
      #9#9', @soundUrl'
      #9#9', @video'
      #9#9', @videoUrl'
      #9#9', @canNextPage'
      #9#9', @canPrevPage'
      #9#9', @active '
      #9#9', @deleted '
      #9#9', @createdAtId'
      #9#9', @createdById'
      #9#9', @created'
      #9#9', @lastChanged'
      #9#9', @changed '
      #9#9', @lastChangedLog'
      #9')'
      
        #9'SET @pageId = (SELECT TRAINING_PROGRAM_PAGE_ID FROM Training_Pr' +
        'ogram_Pages WHERE ROW_COUNTER = SCOPE_IDENTITY())'
      'END'
      'ELSE'
      'BEGIN'
      #9'UPDATE Training_Program_Pages SET'
      
        #9#9'--, TRAINING_PROGRAM_PAGE_ID = ISNULL(@pageId, TRAINING_PROGRA' +
        'M_PAGE_ID)'
      #9#9'TRAINING_PROGRAM_ID = ISNULL(@programId, TRAINING_PROGRAM_ID)'
      
        #9#9', TRAINING_PROGRAM_PAGE_PARENT_ID = ISNULL(@parentId, TRAINING' +
        '_PROGRAM_PAGE_PARENT_ID)'
      
        #9#9', TRAINING_PROGRAM_PAGE_NAME = ISNULL(@name, TRAINING_PROGRAM_' +
        'PAGE_NAME)'
      
        #9#9', TRAINING_PROGRAM_PAGE_SEQUENCE = ISNULL(@sequence, TRAINING_' +
        'PROGRAM_PAGE_SEQUENCE)'
      
        #9#9', TRAINING_PROGRAM_PAGE_CATEGORY_ID = ISNULL(@categoryId, TRAI' +
        'NING_PROGRAM_PAGE_CATEGORY_ID)'
      
        #9#9', TRAINING_PROGRAM_PAGE_TEMPLATE_ID = ISNULL(@templateId, TRAI' +
        'NING_PROGRAM_PAGE_TEMPLATE_ID)'
      
        #9#9', TRAINING_PROGRAM_PAGE_CONTENT = ISNULL(@content, TRAINING_PR' +
        'OGRAM_PAGE_CONTENT)'
      
        #9#9', MINIMUM_REVIEW_TIME = ISNULL(@reviewTime, MINIMUM_REVIEW_TIM' +
        'E)'
      
        #9#9', MAXIMUM_COMPLETION_TIME = ISNULL(@completionTime, MAXIMUM_CO' +
        'MPLETION_TIME)'
      
        #9#9', TRAINING_PROGRAM_PAGE_MULTI_SELECT = ISNULL(@multiSelect, TR' +
        'AINING_PROGRAM_PAGE_MULTI_SELECT)'
      
        #9#9', TRAINING_PROGRAM_PAGE_SCORE_METHOD = ISNULL(@scoreMethod, TR' +
        'AINING_PROGRAM_PAGE_SCORE_METHOD)'
      
        #9#9', TRAINING_PROGRAM_PAGE_SOUND = ISNULL(@sound, TRAINING_PROGRA' +
        'M_PAGE_SOUND)'
      
        #9#9', TRAINING_PROGRAM_PAGE_SOUND_URL = ISNULL(@soundUrl, TRAINING' +
        '_PROGRAM_PAGE_SOUND_URL)'
      
        #9#9', TRAINING_PROGRAM_PAGE_VIDEO = ISNULL(@video, TRAINING_PROGRA' +
        'M_PAGE_VIDEO)'
      
        #9#9', TRAINING_PROGRAM_PAGE_VIDEO_URL = ISNULL(@videoUrl, TRAINING' +
        '_PROGRAM_PAGE_VIDEO_URL)'
      
        #9#9', CAN_NAVIGATE_TO_NEXT_PAGE = ISNULL(@canNextPage, CAN_NAVIGAT' +
        'E_TO_NEXT_PAGE)'
      
        #9#9', CAN_NAVIGATE_TO_PREVIOUS_PAGE = ISNULL(@canPrevPage, CAN_NAV' +
        'IGATE_TO_PREVIOUS_PAGE)'
      #9#9', ACTIVE = ISNULL(@active, ACTIVE)'
      #9#9', REC_DELETED = ISNULL(@deleted, REC_DELETED)'
      #9#9', CREATED_AT_ID = ISNULL(@createdAtId, CREATED_AT_ID)'
      #9#9', CREATED_BY_ID = ISNULL(@createdById, CREATED_BY_ID)'
      #9#9', CREATED = ISNULL(@created, CREATED)'
      #9#9', LAST_CHANGED= GETDATE()'
      #9#9', CHANGED = 1'
      
        #9#9', LAST_CHANGE_LOG_ID = ISNULL(@lastChangedLog, LAST_CHANGE_LOG' +
        '_ID)'
      #9'WHERE TRAINING_PROGRAM_PAGE_ID = @pageId'
      'END'
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      'SELECT'
      #9'pages.ACTIVE AS '#39'active'#39
      #9', pages.CAN_NAVIGATE_TO_NEXT_PAGE AS '#39'canNextPage'#39
      #9', pages.CAN_NAVIGATE_TO_PREVIOUS_PAGE AS '#39'canPrevPage'#39
      #9', pages.CHANGED AS '#39'changed'#39
      #9', pages.CREATED AS '#39'created'#39
      #9', pages.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', pages.CREATED_BY_ID AS '#39'createdById'#39
      #9', pages.GUID AS '#39'id'#39
      #9', pages.LAST_CHANGED AS '#39'lastChanged'#39
      #9', pages.LAST_CHANGE_LOG_ID AS '#39'lastChangedLog'#39
      #9', pages.MAXIMUM_COMPLETION_TIME AS '#39'completionTime'#39
      #9', pages.MINIMUM_REVIEW_TIME AS '#39'reviewTime'#39
      #9', pages.REC_DELETED AS '#39'deleted'#39
      #9', pages.ROW_COUNTER AS '#39'rowCounter'#39
      
        #9'--, pages.TRAINING_PROGRAM_ID AS '#39'programId'#39' -- todo i am retur' +
        'ning guid back'
      #9', @programGuid AS '#39'programId'#39' '
      #9', pages.TRAINING_PROGRAM_PAGE_CATEGORY_ID AS '#39'categoryId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_CONTENT AS '#39'content'#39
      #9', pages.TRAINING_PROGRAM_PAGE_ID AS '#39'pageId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_MULTI_SELECT AS '#39'multiSelect'#39
      #9', pages.TRAINING_PROGRAM_PAGE_NAME AS '#39'title'#39
      ''
      #9', (   '
      #9'-- todo - inefficient '
      #9'CASE WHEN '
      
        #9'(SELECT GUID FROM Training_Program_Pages WHERE TRAINING_PROGRAM' +
        '_PAGE_ID = pages.TRAINING_PROGRAM_PAGE_PARENT_ID)'
      #9'IS NULL THEN '
      #9'NULL '
      #9'ELSE '
      #9'CONCAT('#39'{'#39
      
        #9', CAST((SELECT GUID FROM Training_Program_Pages WHERE TRAINING_' +
        'PROGRAM_PAGE_ID = pages.TRAINING_PROGRAM_PAGE_PARENT_ID) AS CHAR' +
        '(36))'
      #9', '#39'}'#39
      #9')'
      #9
      #9'END'
      #9#9') AS '#39'parentId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SCORE_METHOD AS '#39'scoreMethod'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SEQUENCE AS '#39'sequence'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SOUND AS '#39'sound'#39
      #9', pages.TRAINING_PROGRAM_PAGE_SOUND_URL AS '#39'soundUrl'#39
      #9', pages.TRAINING_PROGRAM_PAGE_TEMPLATE_ID AS '#39'templateId'#39
      #9', pages.TRAINING_PROGRAM_PAGE_VIDEO AS '#39'video'#39
      #9', pages.TRAINING_PROGRAM_PAGE_VIDEO_URL AS '#39'videoUrl'#39
      ''
      #9'-- below are custom arguments to give to tree'
      #9' , 1 AS '#39'expanded'#39
      #9' ,('
      #9#9'CASE WHEN '
      #9#9'TRAINING_PROGRAM_PAGE_CATEGORY_ID = 2 -- page'
      #9#9'THEN '
      #9#9'1'
      #9#9'ELSE '
      #9#9'0 '
      #9#9'END'
      #9#9') AS '#39'leaf'#39
      ''
      ', 1 AS '#39'loaded'#39
      ''
      'FROM Training_Program_Pages AS pages'
      'WHERE pages.REC_DELETED = 0'
      'AND pages.TRAINING_PROGRAM_PAGE_ID = @pageId')
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <
      item
        Name = 'id'
        DataType = ftGuid
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end>
    DeleteQuery.SQL.Strings = (
      'UPDATE Training_Program_Pages'
      'SET REC_DELETED = 1'
      'WHERE GUID = :id'
      '')
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 216
    Top = 56
  end
  object Questions: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <
      item
        Name = 'pageId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'id'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'programId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE @pageIdGuid NVARCHAR(38) = :pageId'
      'DECLARE @questionGuid NVARCHAR(38) = :id'
      'DECLARE @pageId INT = NULL -- gets set later'
      'DECLARE @programGuid NVARCHAR(38) = :programId'
      'DECLARE @programId INT = NULL -- gets set later'
      ''
      ''
      
        'SET @pageId = (SELECT TRAINING_PROGRAM_PAGE_ID FROM Training_Pro' +
        'gram_Pages WHERE GUID = @pageIdGuid) '
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @programGuid) '
      'SELECT'
      #9'questions.GUID AS '#39'id'#39' -- todo returning guid'
      #9', pages.GUID AS '#39'pageId'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_SEQUENCE AS '#39'sequence'#39
      #9', questions.TRAINING_PROGRAM_QUESTION AS '#39'question'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_FIELD_TYPE AS '#39'fieldType'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_FIELD_SIZE AS '#39'fieldSize'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_REQUIRED AS '#39'required'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_LOOKUPS AS '#39'lookups'#39
      
        #9', questions.TRAINING_PROGRAM_QUESTION_CORRECT_VALUE AS '#39'correct' +
        'Value'#39
      #9', questions.TRAINING_PROGRAM_QUESTION_SCORE AS '#39'score'#39
      #9', questions.ACTIVE AS '#39'active'#39
      #9', questions.REC_DELETED AS '#39'deleted'#39
      #9', questions.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', questions.CREATED_BY_ID AS '#39'createdById'#39
      #9', questions.CREATED AS '#39'created'#39
      #9', questions.LAST_CHANGED AS '#39'lastChanged'#39
      #9', questions.CHANGED AS '#39'changed'#39
      #9', questions.LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Training_Program_Questions AS questions'
      ''
      'JOIN Training_Program_Pages AS pages'
      
        'ON (pages.TRAINING_PROGRAM_PAGE_ID = questions.TRAINING_PROGRAM_' +
        'PAGE_ID)'
      ''
      'WHERE questions.REC_DELETED = 0'
      
        'AND (@pageId IS NULL OR (questions.TRAINING_PROGRAM_PAGE_ID = @p' +
        'ageId))'
      'AND (@questionGuid IS NULL OR (questions.GUID = @questionGuid))'
      
        'AND (@programId IS NULL OR (pages.TRAINING_PROGRAM_ID = @program' +
        'Id))'
      '')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.Parameters = <
      item
        Name = 'id'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'pageId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'question'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 500
        Value = Null
      end
      item
        Name = 'fieldType'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = Null
      end
      item
        Name = 'answers'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 1000
        Value = Null
      end
      item
        Name = 'correctValue'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 100
        Value = Null
      end>
    InsertQuery.SQL.Strings = (
      'DECLARE @id NVARCHAR(38) = :id -- this is question guid'
      'DECLARE @questionId INT = NULL -- gets set later'
      'DECLARE @pageIdGuid NVARCHAR(38) = :pageId'
      'DECLARE @pageId INT = NULL -- gets set later'
      'DECLARE @questionSequence INT = NULL'
      'DECLARE @question NVARCHAR(500) = :question'
      'DECLARE @fieldType VARCHAR(20) = :fieldType'
      'DECLARE @fieldSize INT = NULL'
      'DECLARE @required BIT = 1'
      
        'DECLARE @lookups NVARCHAR(1000) = :answers -- here are written a' +
        'll answers with their guids, values, text...'
      
        'DECLARE @correctValue NVARCHAR(100) = :correctValue -- written a' +
        'll guids for correct answers'
      'DECLARE @score NUMERIC(18,2) = NULL'
      'DECLARE @active BIT = 1'
      'DECLARE @deleted BIT = 0'
      'DECLARE @createdAtId INT = NULL'
      'DECLARE @createdById INT = NULL'
      'DECLARE @created DATETIME = GETDATE()'
      'DECLARE @lastChanged DATETIME = GETDATE()'
      'DECLARE @changed CHAR(1) = 0'
      'DECLARE @changeLogId BIGINT = 1'
      ''
      
        'SET @questionId = (SELECT TRAINING_PROGRAM_QUESTION_ID FROM Trai' +
        'ning_Program_Questions WHERE GUID = @id)'
      
        'SET @pageId = (SELECT TRAINING_PROGRAM_PAGE_ID FROM Training_Pro' +
        'gram_Pages WHERE GUID = @pageIdGuid) '
      ''
      ''
      'IF @questionId IS NULL'
      'BEGIN'
      #9'INSERT INTO Training_Program_Questions('
      #9#9'  GUID'
      #9#9'  , TRAINING_PROGRAM_QUESTION_ID'
      #9#9'  , TRAINING_PROGRAM_PAGE_ID'
      #9#9'  , TRAINING_PROGRAM_QUESTION_SEQUENCE'
      #9#9'  , TRAINING_PROGRAM_QUESTION'
      #9#9'  , TRAINING_PROGRAM_QUESTION_FIELD_TYPE'
      #9#9'  , TRAINING_PROGRAM_QUESTION_FIELD_SIZE'
      #9#9'  , TRAINING_PROGRAM_QUESTION_REQUIRED'
      #9#9'  , TRAINING_PROGRAM_QUESTION_LOOKUPS'
      #9#9'  , TRAINING_PROGRAM_QUESTION_CORRECT_VALUE'
      #9#9'  , TRAINING_PROGRAM_QUESTION_SCORE'
      #9#9'  , ACTIVE'
      #9#9'  , REC_DELETED'
      #9#9'  , CREATED_AT_ID'
      #9#9'  , CREATED_BY_ID'
      #9#9'  , CREATED'
      #9#9'  , LAST_CHANGED'
      #9#9'  , CHANGED'
      #9#9'  , LAST_CHANGE_LOG_ID'
      #9#9')'
      #9'VALUES ('
      #9#9'@id'
      #9#9', @questionId'
      #9#9', @pageId'
      #9#9', @questionSequence'
      #9#9', @question'
      #9#9', @fieldType'
      #9#9', @fieldSize'
      #9#9', @required'
      #9#9', @lookups'
      #9#9', @correctValue'
      #9#9', @score'
      #9#9', @active'
      #9#9', @deleted'
      #9#9', @createdAtId'
      #9#9', @createdById'
      #9#9', @created'
      #9#9', @lastChanged'
      #9#9', @changed'
      #9#9', @changeLogId'
      #9')'
      
        #9'SET @questionId = (SELECT TRAINING_PROGRAM_QUESTION_ID FROM Tra' +
        'ining_Program_Questions WHERE ROW_COUNTER = SCOPE_IDENTITY())'
      'END'
      'ELSE'
      'BEGIN'
      #9'SET @deleted = 1'
      #9'SET @changed = 1'
      ''
      ''
      #9'UPDATE Training_Program_Questions SET'
      
        #9#9'TRAINING_PROGRAM_QUESTION_ID = ISNULL(@questionId, TRAINING_PR' +
        'OGRAM_QUESTION_ID)'
      
        #9#9', TRAINING_PROGRAM_PAGE_ID = ISNULL(@pageId, TRAINING_PROGRAM_' +
        'PAGE_ID)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_SEQUENCE = ISNULL(@questionSequenc' +
        'e, TRAINING_PROGRAM_QUESTION_SEQUENCE)'
      
        #9#9', TRAINING_PROGRAM_QUESTION = ISNULL(@question, TRAINING_PROGR' +
        'AM_QUESTION)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_FIELD_TYPE = ISNULL(@fieldType, TR' +
        'AINING_PROGRAM_QUESTION_FIELD_TYPE)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_FIELD_SIZE = ISNULL(@fieldSize, TR' +
        'AINING_PROGRAM_QUESTION_FIELD_SIZE)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_REQUIRED = ISNULL(@required, TRAIN' +
        'ING_PROGRAM_QUESTION_REQUIRED)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_LOOKUPS = ISNULL(@lookups, TRAININ' +
        'G_PROGRAM_QUESTION_LOOKUPS)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_CORRECT_VALUE = ISNULL(@correctVal' +
        'ue, TRAINING_PROGRAM_QUESTION_CORRECT_VALUE)'
      
        #9#9', TRAINING_PROGRAM_QUESTION_SCORE = ISNULL(@score, TRAINING_PR' +
        'OGRAM_QUESTION_SCORE)'
      #9#9', ACTIVE = ISNULL(@active, ACTIVE)'
      #9#9', REC_DELETED = ISNULL(@deleted, REC_DELETED)'
      #9#9', CREATED_AT_ID = ISNULL(@createdAtId, CREATED_AT_ID)'
      #9#9', CREATED_BY_ID = ISNULL(@createdById, CREATED_BY_ID)'
      #9#9', CREATED = ISNULL(@created, CREATED)'
      #9#9', LAST_CHANGED = ISNULL(@lastChanged, LAST_CHANGED)'
      #9#9', CHANGED = ISNULL(@changed, CHANGED)'
      
        #9#9', LAST_CHANGE_LOG_ID = ISNULL(@changeLogId, LAST_CHANGE_LOG_ID' +
        ')'
      #9'WHERE TRAINING_PROGRAM_QUESTION_ID = @questionId'
      'END'
      ''
      'SELECT'
      #9'GUID AS '#39'id'#39' -- todo returning guid'
      #9', @pageIdGuid AS '#39'pageId'#39' -- todo returning page id guid'
      #9', TRAINING_PROGRAM_QUESTION_SEQUENCE AS '#39'sequence'#39
      #9', TRAINING_PROGRAM_QUESTION AS '#39'question'#39
      #9', TRAINING_PROGRAM_QUESTION_FIELD_TYPE AS '#39'fieldType'#39
      #9', TRAINING_PROGRAM_QUESTION_FIELD_SIZE AS '#39'fieldSize'#39
      #9', TRAINING_PROGRAM_QUESTION_REQUIRED AS '#39'required'#39
      #9', TRAINING_PROGRAM_QUESTION_LOOKUPS AS '#39'lookups'#39
      #9', TRAINING_PROGRAM_QUESTION_CORRECT_VALUE AS '#39'correctValue'#39
      #9', TRAINING_PROGRAM_QUESTION_SCORE AS '#39'score'#39
      #9', ACTIVE AS '#39'active'#39
      #9', REC_DELETED AS '#39'deleted'#39
      #9', CREATED_AT_ID AS '#39'createdAtId'#39
      #9', CREATED_BY_ID AS '#39'createdById'#39
      #9', CREATED AS '#39'created'#39
      #9', LAST_CHANGED AS '#39'lastChanged'#39
      #9', CHANGED AS '#39'changed'#39
      #9', LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Training_Program_Questions AS questions'
      'WHERE questions.REC_DELETED = 0'
      'AND questions.TRAINING_PROGRAM_QUESTION_ID = @questionId')
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <
      item
        Name = 'id'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end>
    DeleteQuery.SQL.Strings = (
      'UPDATE Training_Program_Questions'
      'SET REC_DELETED = 1'
      'WHERE GUID = :id')
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 216
    Top = 104
  end
  object PersonAnswers: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <
      item
        Name = 'programId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'questionGuid'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end>
    SQL.Strings = (
      
        '-- this query is retrieving latest answers for this program if p' +
        'rogramId is recieved,'
      
        '-- othewrise it is retrieving all answers for this question if q' +
        'uestionGuid is set'
      ''
      'DECLARE @programGuid NVARCHAR(38) = :programId'
      'DECLARE @programId INT = NULL -- gets set later '
      'DECLARE @questionGuid NVARCHAR(38) = :questionGuid'
      'DECLARE @questionId INT = NULL -- gets set later '
      
        'SET @questionId = (SELECT training_program_question_id FROM trai' +
        'ning_program_questions WHERE  GUID = @questionGuid) '
      
        'SET @programId = (SELECT training_program_id FROM training_progr' +
        'ams WHERE GUID = @programGuid) '
      ''
      'IF @questionId IS NULL'
      'BEGIN'
      'SELECT'
      #9'answers.GUID '#39'questionGuid'#39' -- todo returning guid'
      #9', answers.PERSON_TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', answers.TRAINING_PROGRAM_QUESTION_ID AS '#39'questionId'#39
      #9', answers.TRAINING_PROGRAM_ANSWER AS '#39'answer'#39
      #9', answers.TRAINING_PROGRAM_ANSWER_SCORE AS '#39'score'#39
      #9', answers.CREATED_AT_ID AS '#39'createdAtId'#39
      #9', answers.CREATED_BY_ID AS '#39'createdById'#39
      #9', answers.CREATED AS '#39'created'#39
      #9', answers.LAST_CHANGED AS '#39'lastChanged'#39
      #9', answers.CHANGED AS '#39'changed'#39
      #9', answers.LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM   person_training_program_answers AS answers '
      '       JOIN person_training_programs AS personPrograms '
      
        '         ON( personPrograms.person_training_program_id = answers' +
        '.person_training_program_id ) '
      '       JOIN (SELECT Max(answers.last_changed) AS '#39'lastChanged'#39' '
      #9#9#9#9', answers.TRAINING_PROGRAM_QUESTION_ID AS '#39'questionId'#39
      '             FROM   person_training_program_answers AS answers '
      
        '                    JOIN person_training_programs AS personProgr' +
        'ams '
      
        '                      ON( personPrograms.person_training_program' +
        '_id = answers.person_training_program_id ) '
      
        '             WHERE  ( @questionId IS NULL  OR ( answers.training' +
        '_program_question_id = @questionId )  )  -- get answer for speci' +
        'fic question '
      
        '                    AND ( @programId IS NULL  OR ( personProgram' +
        's.training_program_id = @programId ) )   -- get all answers for ' +
        'personProgram '
      '             GROUP  BY answers.person_training_program_id, '
      
        '                       answers.training_program_question_id) AS ' +
        '"LatestAnswers" '
      
        '         ON( "LatestAnswers".questionId = answers.training_progr' +
        'am_question_id ) '
      'WHERE  "LatestAnswers".lastchanged = "answers".last_changed '
      'END'
      'ELSE'
      'BEGIN'
      'SELECT'
      #9'  PERSON_TRAINING_PROGRAM_ANSWER_ID AS '#39'id'#39
      #9', PERSON_TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', TRAINING_PROGRAM_QUESTION_ID AS '#39'questionId'#39
      #9', TRAINING_PROGRAM_ANSWER AS '#39'answer'#39
      #9', TRAINING_PROGRAM_ANSWER_SCORE AS '#39'score'#39
      #9', CREATED_AT_ID AS '#39'createdAtId'#39
      #9', CREATED_BY_ID AS '#39'createdById'#39
      #9', CREATED AS '#39'created'#39
      #9', LAST_CHANGED AS '#39'lastChanged'#39
      #9', CHANGED AS '#39'changed'#39
      #9', LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Person_Training_Program_Answers AS answers'
      'WHERE answers.TRAINING_PROGRAM_QUESTION_ID = @questionId'
      ''
      'END'
      '')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.Parameters = <
      item
        Name = 'answerGuid'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'personProgramId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'questionId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'answers'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 500
        Value = Null
      end
      item
        Name = 'score'
        DataType = ftFloat
        NumericScale = 18
        Precision = 2
        Size = -1
        Value = Null
      end>
    InsertQuery.SQL.Strings = (
      
        'DECLARE @answerGuid NVARCHAR(38) = :answerGuid -- this is answer' +
        ' id'
      'DECLARE @answerId INT = NULL -- gets set later'
      'DECLARE @personProgramGuid NVARCHAR(38) = :personProgramId'
      'DECLARE @personProgramid INT = NULL -- gets set later'
      'DECLARE @questionGuid NVARCHAR(38) = :questionId'
      'DECLARE @questionId INT = NULL -- gets set later'
      'DECLARE @answer NVARCHAR(500) = :answers'
      'DECLARE @answerScore NUMERIC(18,2) = :score'
      'DECLARE @createdAtId INT = NULL'
      'DECLARE @createdById INT = NULL'
      'DECLARE @created DATETIME = GETDATE()'
      'DECLARE @lastChanged DATETIME = GETDATE()'
      'DECLARE @changed CHAR(1) = 0'
      'DECLARE @changeLogId BIGINT = 1'
      ''
      '-- get ids from guids'
      
        'SET @answerId = (SELECT PERSON_TRAINING_PROGRAM_ANSWER_ID FROM P' +
        'erson_Training_Program_Answers WHERE GUID = @answerGuid)'
      
        'SET @personProgramid = (SELECT PERSON_TRAINING_PROGRAM_ID FROM P' +
        'erson_Training_Programs WHERE GUID = @personProgramGuid)'
      
        'SET @questionId = (SELECT TRAINING_PROGRAM_QUESTION_ID FROM Trai' +
        'ning_Program_Questions WHERE GUID = @questionGuid)'
      ''
      'IF @answerId IS NULL'
      'BEGIN'
      #9'INSERT INTO Person_Training_Program_Answers('
      #9#9'  GUID'
      #9#9'  -- , PERSON_TRAINING_PROGRAM_ANSWER_ID'
      #9#9'  , PERSON_TRAINING_PROGRAM_ID'
      #9#9'  , TRAINING_PROGRAM_QUESTION_ID'
      #9#9'  , TRAINING_PROGRAM_ANSWER'
      #9#9'  , TRAINING_PROGRAM_ANSWER_SCORE'
      #9#9'  , CREATED_AT_ID'
      #9#9'  , CREATED_BY_ID'
      #9#9'  , CREATED'
      #9#9'  , LAST_CHANGED'
      #9#9'  , CHANGED'
      #9#9'  , LAST_CHANGE_LOG_ID'
      #9#9')'
      #9'VALUES ('
      #9#9'@answerGuid '
      #9#9'-- , @answerId'
      #9#9', @personProgramid'
      #9#9', @questionId'
      #9#9', @answer'
      #9#9', @answerScore '
      #9#9', @createdAtId '
      #9#9', @createdById '
      #9#9', @created'
      #9#9', @lastChanged'
      #9#9', @changed'
      #9#9', @changeLogId'
      #9#9')'
      ''
      
        #9'SET @answerId = (SELECT PERSON_TRAINING_PROGRAM_ANSWER_ID FROM ' +
        'Person_Training_Program_Answers WHERE ROW_COUNTER = SCOPE_IDENTI' +
        'TY())'
      'END'
      'ELSE'
      'BEGIN'
      #9'SET @changed = 1'
      #9'SET @lastChanged = GETDATE()'
      ''
      ''
      #9'UPDATE Person_Training_Program_Answers SET'
      #9#9#9'GUID = ISNULL(@answerGuid, GUID)'
      
        #9#9#9'-- PERSON_TRAINING_PROGRAM_ANSWER_ID = ISNULL(@answerId, PERS' +
        'ON_TRAINING_PROGRAM_ANSWER_ID)'
      
        #9#9'  ,  PERSON_TRAINING_PROGRAM_ID = ISNULL(@personProgramid, PER' +
        'SON_TRAINING_PROGRAM_ID)'
      
        #9#9'  , TRAINING_PROGRAM_QUESTION_ID = ISNULL(@questionId, TRAININ' +
        'G_PROGRAM_QUESTION_ID)'
      
        #9#9'  , TRAINING_PROGRAM_ANSWER = ISNULL(@answer, TRAINING_PROGRAM' +
        '_ANSWER)'
      
        #9#9'  , TRAINING_PROGRAM_ANSWER_SCORE = ISNULL(@answerScore, TRAIN' +
        'ING_PROGRAM_ANSWER_SCORE)'
      #9#9'  , CREATED_AT_ID = ISNULL(@createdAtId, CREATED_AT_ID)'
      #9#9'  , CREATED_BY_ID = ISNULL(@createdById, CREATED_BY_ID)'
      #9#9'  , CREATED = ISNULL(@created, CREATED)'
      #9#9'  , LAST_CHANGED = ISNULL(@lastChanged, LAST_CHANGED)'
      #9#9'  , CHANGED = ISNULL(@changed, CHANGED)'
      
        #9#9'  , LAST_CHANGE_LOG_ID = ISNULL(@changeLogId, LAST_CHANGE_LOG_' +
        'ID)'
      #9'WHERE PERSON_TRAINING_PROGRAM_ANSWER_ID = @answerId'
      'END'
      ''
      'SELECT'
      #9'  PERSON_TRAINING_PROGRAM_ANSWER_ID AS '#39'id'#39
      #9', PERSON_TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', TRAINING_PROGRAM_QUESTION_ID AS '#39'questionId'#39
      #9', TRAINING_PROGRAM_ANSWER AS '#39'answer'#39
      #9', TRAINING_PROGRAM_ANSWER_SCORE AS '#39'score'#39
      #9', CREATED_AT_ID AS '#39'createdAtId'#39
      #9', CREATED_BY_ID AS '#39'createdById'#39
      #9', CREATED AS '#39'created'#39
      #9', LAST_CHANGED AS '#39'lastChanged'#39
      #9', CHANGED AS '#39'changed'#39
      #9', LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Person_Training_Program_Answers AS answers'
      'WHERE answers.PERSON_TRAINING_PROGRAM_ANSWER_ID = @answerId')
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 216
    Top = 152
  end
  object PersonPrograms: TADOQueryMX
    Connection = ADOConnection1
    Parameters = <
      item
        Name = 'personId'
        Size = -1
        Value = Null
      end
      item
        Name = 'programId'
        Size = -1
        Value = Null
      end
      item
        Name = 'personTrainingProgramGuid'
        DataType = ftGuid
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      '-- select by person id and programGuid or by its own guid'
      'DECLARE @personId INT = :personId'
      'DECLARE @programGuid NVARCHAR(38) = :programId'
      'DECLARE @programId INT = NULL -- gets set later'
      ''
      
        'DECLARE @personTrainingProgramGuid NVARCHAR(38) = :personTrainin' +
        'gProgramGuid'
      'DECLARE @personTrainingProgramId INT = NULL -- gets set later'
      ''
      
        'SET @personTrainingProgramId = (SELECT PERSON_TRAINING_PROGRAM_I' +
        'D FROM Person_Training_Programs WHERE GUID = @personTrainingProg' +
        'ramGuid)'
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @programGuid)'
      ''
      'SELECT'
      #9'--PERSON_TRAINING_PROGRAM_ID AS '#39'personTrainingProgramId'#39
      #9'GUID AS '#39'personTrainingProgramId'#39' -- todo returning guid'
      #9', PERSON_APPLICANT_ID AS '#39'applicantId'#39
      #9', PERSON_ID AS '#39'personId'#39
      #9', TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', PERSON_TRAINING_PROGRAM_STARTED AS '#39'programStarted'#39
      #9', PERSON_TRAINING_PROGRAM_COMPLETED AS '#39'programCompleted'#39
      #9', COMMENT_EMPLOYEE AS '#39'commentEmployee'#39
      #9', COMMENT_INTERNAL AS '#39'commentInternal'#39
      #9', PERSON_TRAINING_PROGRAM_STATUS_ID AS '#39'programStatusId'#39
      #9', ATTEMPT_COUNTER AS '#39'attempt'#39
      #9', CREATED_AT_ID AS '#39'createdAtId'#39
      #9', CREATED_BY_ID AS '#39'createdById'#39
      #9', CREATED AS '#39'created'#39
      #9', LAST_CHANGED AS '#39'lastChanged'#39
      #9', CHANGED AS '#39'changed'#39
      #9', LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Person_Training_Programs AS personPrograms'
      
        'WHERE (@personTrainingProgramId IS NULL OR (personPrograms.PERSO' +
        'N_TRAINING_PROGRAM_ID = @personTrainingProgramId))'
      
        'AND (@personId IS NULL OR  @programId IS NULL OR (personPrograms' +
        '.TRAINING_PROGRAM_ID = @programId AND personPrograms.PERSON_ID =' +
        ' @personId))')
    InsertQuery.Connection = ADOConnection1
    InsertQuery.Parameters = <
      item
        Name = 'personProgramGuid'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'personId'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'programId'
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 38
        Value = Null
      end
      item
        Name = 'programStatusId'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'attempt'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'createdById'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'created'
        DataType = ftDateTime
        Size = -1
        Value = Null
      end>
    InsertQuery.SQL.Strings = (
      
        'DECLARE @personTrainingProgramGuid NVARCHAR(38) = :personProgram' +
        'Guid'
      'DECLARE @personTrainingProgramId INT = NULL -- gets set later'
      'DECLARE @applicantId INT = NULL'
      'DECLARE @personId INT = :personId'
      'DECLARE @programGuid NVARCHAR(38) = :programId'
      'DECLARE @programId INT = NULL -- gets set later'
      'DECLARE @programStarted DATETIME = NULL'
      'DECLARE @programCompleted DATETIME = NULL'
      'DECLARE @commentEmployee NVARCHAR(2000) = NULL'
      'DECLARE @commentInternal NVARCHAR(2000) = NULL'
      'DECLARE @programStatusId INT = :programStatusId'
      'DECLARE @attempt INT = :attempt'
      'DECLARE @createdAtId INT = NULL'
      'DECLARE @createdById INT = :createdById'
      'DECLARE @created DATETIME = :created'
      'DECLARE @lastChanged DATETIME = GETDATE()'
      'DECLARE @changed CHAR(1) = 0'
      'DECLARE @changeLogId BIGINT = 1'
      ''
      
        'SET @personTrainingProgramId = (SELECT PERSON_TRAINING_PROGRAM_I' +
        'D FROM Person_Training_Programs WHERE GUID = @personTrainingProg' +
        'ramGuid)'
      
        'SET @programId = (SELECT TRAINING_PROGRAM_ID FROM Training_Progr' +
        'ams WHERE GUID = @programGuid)'
      ''
      'IF @personTrainingProgramId IS NULL'
      'BEGIN'
      #9'INSERT INTO Person_Training_Programs('
      #9#9'  GUID'
      #9#9'  -- , PERSON_TRAINING_PROGRAM_ID'
      #9#9'  , PERSON_APPLICANT_ID'
      #9#9'  , PERSON_ID'
      #9#9'  , TRAINING_PROGRAM_ID'
      #9#9'  , PERSON_TRAINING_PROGRAM_STARTED'
      #9#9'  , PERSON_TRAINING_PROGRAM_COMPLETED'
      #9#9'  , COMMENT_EMPLOYEE'
      #9#9'  , COMMENT_INTERNAL'
      #9#9'  , PERSON_TRAINING_PROGRAM_STATUS_ID'
      #9#9'  , ATTEMPT_COUNTER'
      #9#9'  , CREATED_BY_ID'
      #9#9'  , CREATED_AT_ID'
      #9#9'  , CREATED'
      #9#9'  , LAST_CHANGED'
      #9#9'  , CHANGED'
      #9#9'  , LAST_CHANGE_LOG_ID'
      #9#9'  '
      #9#9')'
      #9'VALUES ('
      #9#9'@personTrainingProgramGuid '
      #9#9'-- , @personTrainingProgramId'
      #9#9', @applicantId'
      #9#9', @personId'
      #9#9', @programId'
      #9#9', @programStarted'
      #9#9', @programCompleted'
      #9#9', @commentEmployee'
      #9#9', @commentInternal'
      #9#9', @programStatusId'
      #9#9', @attempt '
      #9#9', @createdAtId '
      #9#9', @createdById '
      #9#9', @created'
      #9#9', @lastChanged'
      #9#9', @changed'
      #9#9', @changeLogId'
      #9#9')'
      ''
      
        #9'SET @personTrainingProgramId = (SELECT PERSON_TRAINING_PROGRAM_' +
        'ID FROM Person_Training_Programs WHERE ROW_COUNTER = SCOPE_IDENT' +
        'ITY())'
      'END'
      'ELSE'
      'BEGIN'
      #9'SET @changed = 1'
      #9'SET @lastChanged = GETDATE()'
      ''
      #9'UPDATE Person_Training_Programs SET'
      
        #9#9'    -- PERSON_TRAINING_PROGRAM_ID = ISNULL(@personTrainingProg' +
        'ramId, PERSON_TRAINING_PROGRAM_ID)'
      
        #9#9'    PERSON_APPLICANT_ID = ISNULL(@applicantId, PERSON_APPLICAN' +
        'T_ID)'
      #9#9'  , PERSON_ID = ISNULL(@personId, PERSON_ID)'
      
        #9#9'  , TRAINING_PROGRAM_ID = ISNULL(@programId, TRAINING_PROGRAM_' +
        'ID)'
      
        #9#9'  , PERSON_TRAINING_PROGRAM_STARTED = ISNULL(@programStarted, ' +
        'PERSON_TRAINING_PROGRAM_STARTED)'
      
        #9#9'  , PERSON_TRAINING_PROGRAM_COMPLETED = ISNULL(@programComplet' +
        'ed, PERSON_TRAINING_PROGRAM_COMPLETED)'
      
        #9#9'  , COMMENT_EMPLOYEE = ISNULL(@commentEmployee, COMMENT_EMPLOY' +
        'EE)'
      
        #9#9'  , COMMENT_INTERNAL = ISNULL(@commentInternal, COMMENT_INTERN' +
        'AL)'
      
        #9#9'  , PERSON_TRAINING_PROGRAM_STATUS_ID = ISNULL(@programStatusI' +
        'd, PERSON_TRAINING_PROGRAM_STATUS_ID)'
      #9#9'  , ATTEMPT_COUNTER = ISNULL(@attempt, ATTEMPT_COUNTER)'
      #9#9'  , CREATED_BY_ID = ISNULL(@createdAtId, CREATED_BY_ID)'
      #9#9'  , CREATED_AT_ID = ISNULL(@createdById, CREATED_AT_ID)'
      #9#9'  , CREATED = ISNULL(@created, CREATED)'
      #9#9'  , LAST_CHANGED = ISNULL(@lastChanged, LAST_CHANGED)'
      #9#9'  , CHANGED = ISNULL(@changed, CHANGED)'
      
        #9#9'  , LAST_CHANGE_LOG_ID = ISNULL(@changeLogId, LAST_CHANGE_LOG_' +
        'ID)'
      ''
      #9'WHERE PERSON_TRAINING_PROGRAM_ID = @personTrainingProgramId'
      'END'
      ''
      'SELECT'
      #9'-- PERSON_TRAINING_PROGRAM_ID AS '#39'personTrainingProgramId'#39
      #9'GUID AS '#39'personTrainingProgramId'#39' -- todo returning guid'
      #9', PERSON_APPLICANT_ID AS '#39'applicantId'#39
      #9', PERSON_ID AS '#39'personId'#39
      #9', TRAINING_PROGRAM_ID AS '#39'programId'#39
      #9', PERSON_TRAINING_PROGRAM_STARTED AS '#39'programStarted'#39
      #9', PERSON_TRAINING_PROGRAM_COMPLETED AS '#39'programCompleted'#39
      #9', COMMENT_EMPLOYEE AS '#39'commentEmployee'#39
      #9', COMMENT_INTERNAL AS '#39'commentInternal'#39
      #9', PERSON_TRAINING_PROGRAM_STATUS_ID AS '#39'programStatusId'#39
      #9', ATTEMPT_COUNTER AS '#39'attempt'#39
      #9', CREATED_AT_ID AS '#39'createdAtId'#39
      #9', CREATED_BY_ID AS '#39'createdById'#39
      #9', CREATED AS '#39'created'#39
      #9', LAST_CHANGED AS '#39'lastChanged'#39
      #9', CHANGED AS '#39'changed'#39
      #9', LAST_CHANGE_LOG_ID AS '#39'changeLogId'#39
      ''
      'FROM Person_Training_Programs AS personPrograms'
      
        'WHERE personPrograms.PERSON_TRAINING_PROGRAM_ID = @personTrainin' +
        'gProgramId')
    DeleteQuery.Connection = ADOConnection1
    DeleteQuery.Parameters = <>
    UpdateQuery.Connection = ADOConnection1
    UpdateQuery.Parameters = <>
    Left = 216
    Top = 200
  end
end
