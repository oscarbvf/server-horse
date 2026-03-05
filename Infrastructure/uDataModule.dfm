object DataModule1: TDataModule1
  OnCreate = DataModuleCreate
  Height = 181
  Width = 499
  object FDConnection1: TFDConnection
    Left = 40
    Top = 56
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 152
    Top = 56
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 272
    Top = 56
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Console'
    Left = 416
    Top = 56
  end
end
