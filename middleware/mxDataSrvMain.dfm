object MXDataServ: TMXDataServ
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'MX Server Service'
  BeforeInstall = ServiceBeforeInstall
  OnExecute = ServiceExecute
  Height = 150
  Width = 215
end
