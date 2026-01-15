## Available Methods and Incoming Data

```java
    public static void DataParsingWithData(byte[] value, final DataListener2301 dataListener) {
        Map<String, String> map = new HashMap<>();
        switch (value[0]) {

            case DeviceConst.CMD_Set_UseInfo:
                dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.SetPersonalInfo));
                break;
            case DeviceConst.CMD_Set_Auto:
                dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.SetAutomatic));
                break;
            case DeviceConst.CMD_Set_DeviceID:
                dataListener.dataCallback(ResolveUtil.setMacSuccessful());
                break;
            case DeviceConst.CMD_SET_TIME:
                dataListener.dataCallback(ResolveUtil.setTimeSuccessful(value));
                break;

            case DeviceConst.CMD_GET_TIME:
                dataListener.dataCallback(ResolveUtil.getDeviceTime(value));
                break;
            case DeviceConst.CMD_GET_USERINFO:
                dataListener.dataCallback(ResolveUtil.getUserInfo(value));
                break;
            case DeviceConst.CMD_Enable_Activity:
                dataListener.dataCallback(ResolveUtil.getActivityData(value));
                break;
            case DeviceConst.CMD_Get_BatteryLevel:
                dataListener.dataCallback(ResolveUtil.getDeviceBattery(value));
                break;
            case DeviceConst.CMD_Get_Address:
                dataListener.dataCallback(ResolveUtil.getDeviceAddress(value));
                break;
            case DeviceConst.CMD_Get_Version:
                dataListener.dataCallback(ResolveUtil.getDeviceVersion(value));
                break;
            case DeviceConst.CMD_Get_Auto:
                dataListener.dataCallback(ResolveUtil.getAutoHeart(value));
                break;
            case DeviceConst.CMD_Reset:
                dataListener.dataCallback(ResolveUtil.Reset());
                break;
            case DeviceConst.CMD_Mcu_Reset:
                dataListener.dataCallback(ResolveUtil.MCUReset());
                break;
            case DeviceConst.CMD_Get_TotalData:
                if (GetTotalActivityDataWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_GetTotalActivityData));
                } else {
                    dataListener.dataCallback(ResolveUtil.getTotalStepData(value));
                }
                break;
            case DeviceConst.CMD_Get_DetailData:
                if (GetDetailActivityDataWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.deleteGetDetailActivityDataWithMode));
                } else {
                    dataListener.dataCallback(ResolveUtil.getDetailData(value));
                }
                break;
            case DeviceConst.CMD_Get_SleepData:
                if (Delete_GetDetailSleepData) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_GetDetailSleepData));
                } else {
                    dataListener.dataCallback(ResolveUtil.getSleepData(value));
                }
                break;
            case DeviceConst.CMD_Get_HeartData:
                if (GetDynamicHRWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_GetDynamicHR));
                } else {
                    dataListener.dataCallback(ResolveUtil.getHeartData(value));
                }

                break;
            case DeviceConst.CMD_Get_OnceHeartData:
                if (GetStaticHRWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_GetStaticHR));
                } else {
                    dataListener.dataCallback(ResolveUtil.getOnceHeartData(value));
                }

                break;
            case DeviceConst.CMD_Get_HrvTestData:
                if (readhrv) {
                    dataListener.dataCallback(ResolveUtil.getHrvTestData(value));
                } else {
                    dataListener.dataCallback(ResolveUtil.DeleteHrv());
                }
                break;
            case DeviceConst.Obtain_detailed_sleep_data:
                if (readgetObtainDetailedSleepData) {
                    dataListener.dataCallback(ResolveUtil.getObtainDetailedSleepData(value));
                } else {
                    dataListener.dataCallback(ResolveUtil.DeletesLEEP());
                }
                break;
            case DeviceConst.Temperature_3NTC:
                dataListener.dataCallback(ResolveUtil.Temperature_3NTC(value));
                break;
            case DeviceConst.SetBasic_parameters_of_equipment:
                dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.SetBasic_parameters_of_equipment));
                break;
            case DeviceConst.GetBasic_parameters_of_equipment:
                dataListener.dataCallback(ResolveUtil.GetBasic_parameters_of_equipment(value));
                break;
            case DeviceConst.ReadTempHisrory:
                if (GetTemperature_historyDataWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.deleteGetTemperature_historyDataWithMode));
                } else {
                    dataListener.dataCallback(ResolveUtil.getTempData(value));
                }
                break;
            case DeviceConst.Oxygen_data:
                if (Obtain_The_data_of_manual_blood_oxygen_test) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_Obtain_The_data_of_manual_blood_oxygen_test));
                } else {
                    dataListener.dataCallback(ResolveUtil.GetAutomaticSpo2Monitoring(value));
                }
                break;
            case DeviceConst.CMD_HeartPackageFromDevice:
                dataListener.dataCallback(ResolveUtil.getActivityExerciseData(value));
                break;
            case DeviceConst.CMD_Set_Name:
                dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.CMD_Set_Name));
                break;
            case DeviceConst.CMD_Get_Name:
                dataListener.dataCallback(ResolveUtil.getDeviceName(value));
                break;
            case DeviceConst.CMD_Get_SPORTData:
                if (GetActivityModeDataWithMode) {
                    dataListener.dataCallback(ResolveUtil.setMethodSuccessful(BleConst.Delete_ActivityModeData));
                } else {
                    dataListener.dataCallback(ResolveUtil.getExerciseData(value));
                }
                break;
            case DeviceConst.MeasurementWithType:
                if (StartDeviceMeasurementWithType) {
                    Map<String, Object> vv = new HashMap<>();
                    switch (value[1]) {
                        case 1://hrv
                            vv.put(DeviceKey.DataType, BleConst.MeasurementHrvCallback);
                            vv.put(DeviceKey.End, true);
                            Map<String, String> lm = new HashMap<>();
                            lm.put(DeviceKey.Type, ResolveUtil.getValue(value[1], 0) + "");
                            lm.put(DeviceKey.HeartRate, ResolveUtil.getValue(value[2], 0) + "");
                            lm.put(DeviceKey.Blood_oxygen, ResolveUtil.getValue(value[3], 0) + "");
                            lm.put(DeviceKey.HRV, ResolveUtil.getValue(value[4], 0) + "");
                            lm.put(DeviceKey.Stress, ResolveUtil.getValue(value[5], 0) + "");
                            lm.put(DeviceKey.HighPressure, ResolveUtil.getValue(value[6], 0) + "");
                            lm.put(DeviceKey.LowPressure, ResolveUtil.getValue(value[7], 0) + "");
                            vv.put(DeviceKey.Data, lm);
                            dataListener.dataCallback(vv);
                            break;
                        case 2://heart
                            vv.put(DeviceKey.DataType, BleConst.MeasurementHeartCallback);
                            vv.put(DeviceKey.End, true);
                            Map<String, String> lmB = new HashMap<>();
                            lmB.put(DeviceKey.Type, ResolveUtil.getValue(value[1], 0) + "");
                            lmB.put(DeviceKey.HeartRate, ResolveUtil.getValue(value[2], 0) + "");
                            lmB.put(DeviceKey.Blood_oxygen, ResolveUtil.getValue(value[3], 0) + "");
                            lmB.put(DeviceKey.HRV, ResolveUtil.getValue(value[4], 0) + "");
                            lmB.put(DeviceKey.Stress, ResolveUtil.getValue(value[5], 0) + "");
                            lmB.put(DeviceKey.HighPressure, ResolveUtil.getValue(value[6], 0) + "");
                            lmB.put(DeviceKey.LowPressure, ResolveUtil.getValue(value[7], 0) + "");
                            vv.put(DeviceKey.Data, lmB);
                            dataListener.dataCallback(vv);
                            break;
                        case 3://0xy
                            vv.put(DeviceKey.DataType, BleConst.MeasurementOxygenCallback);
                            vv.put(DeviceKey.End, true);
                            Map<String, String> lmC = new HashMap<>();
                            lmC.put(DeviceKey.Type, ResolveUtil.getValue(value[1], 0) + "");
                            lmC.put(DeviceKey.HeartRate, ResolveUtil.getValue(value[2], 0) + "");
                            lmC.put(DeviceKey.Blood_oxygen, ResolveUtil.getValue(value[3], 0) + "");
                            lmC.put(DeviceKey.HRV, ResolveUtil.getValue(value[4], 0) + "");
                            lmC.put(DeviceKey.Stress, ResolveUtil.getValue(value[5], 0) + "");
                            lmC.put(DeviceKey.HighPressure, ResolveUtil.getValue(value[6], 0) + "");
                            lmC.put(DeviceKey.LowPressure, ResolveUtil.getValue(value[7], 0) + "");
                            vv.put(DeviceKey.Data, lmC);
                            dataListener.dataCallback(vv);
                            break;
                    }
                } else {
                    Map<String, Object> vv = new HashMap<>();
                    switch (value[1]) {
                        case 1://hrv
                            vv.put(DeviceKey.DataType, BleConst.StopMeasurementHrvCallback);
                            vv.put(DeviceKey.End, true);
                            vv.put(DeviceKey.Data, new HashMap<>());
                            dataListener.dataCallback(vv);
                            break;
                        case 2://heart
                            vv.put(DeviceKey.DataType, BleConst.StopMeasurementHeartCallback);
                            vv.put(DeviceKey.End, true);
                            vv.put(DeviceKey.Data, new HashMap<>());
                            dataListener.dataCallback(vv);
                            break;
                        case 3://0xy
                            vv.put(DeviceKey.DataType, BleConst.StopMeasurementOxygenCallback);
                            vv.put(DeviceKey.End, true);
                            vv.put(DeviceKey.Data, new HashMap<>());
                            dataListener.dataCallback(vv);
                            break;
                    }
                }
                break;
            case DeviceConst.CMD_Get_Bloodsugar:
                if (startBloodsugar) {//只有开始测量才返回状态
                    Map<String, Object> vv = new HashMap<>();
                    vv.put(DeviceKey.DataType, BleConst.Blood_glucose_status);
                    vv.put(DeviceKey.End, true);
                    Map<String, String> lm = new HashMap<>();
                    lm.put(DeviceKey.Type, ResolveUtil.getValue(value[1], 0) + "");
                    vv.put(DeviceKey.Data, lm);
                    dataListener.dataCallback(vv);
                }
                break;
            case DeviceConst.Bloodsugar_data:
                Map<String, Object> vv = new HashMap<>();
                vv.put(DeviceKey.DataType, BleConst.Blood_glucose_data);
                vv.put(DeviceKey.End, false);
                Map<String, String> lm = new HashMap<>();
                // lm.put(DeviceKey.Time, getFormatTimeString(System.currentTimeMillis(), "yyyy.MM.dd HH:mm:ss"));
                List<Integer> simplePpg = new ArrayList<>();
                if (value.length == 153) {//新血糖解析
                    byte[] valueer = new byte[value.length - 3];
                    System.arraycopy(value, 3, valueer, 0, valueer.length);
                    for (int i = 0; i < valueer.length / 3; i++) {
                        int valuedata = ResolveUtil.getValue(valueer[3 * i], 2)
                                + ResolveUtil.getValue(valueer[3 * i + 1], 1)
                                + ResolveUtil.getValue(valueer[3 * i + 2], 0);
                        simplePpg.add(valuedata);
                    }
                    lm.put(DeviceKey.PPG, Arrays.toString(simplePpg.toArray()));
                }
                vv.put(DeviceKey.Data, lm);
                dataListener.dataCallback(vv);
                break;

            case DeviceConst.CMD_Start_EXERCISE:
                if (FindActivityMode) {
                    Map<String, Object> mapEXERCISE = new HashMap<>();
                    mapEXERCISE.put(DeviceKey.DataType, BleConst.FindActivityMode);
                    mapEXERCISE.put(DeviceKey.End, true);
                    Map<String, String> mapsx = new HashMap<>();
                    mapsx.put(DeviceKey.Type, ResolveUtil.getValue(value[1], 0) + "");
                    mapsx.put(DeviceKey.Status, ResolveUtil.getValue(value[2], 0) + "");
                    mapEXERCISE.put(DeviceKey.Data, mapsx);
                    dataListener.dataCallback(mapEXERCISE);
                } else {
                    Map<String, Object> mapEXERCISE = new HashMap<>();
                    mapEXERCISE.put(DeviceKey.DataType, BleConst.EnterActivityMode);
                    mapEXERCISE.put(DeviceKey.End, true);
                    Map<String, String> mapsx = new HashMap<>();
                    mapsx.put(DeviceKey.enterActivityModeSuccess, ResolveUtil.getValue(value[1], 0) + "");
                    mapEXERCISE.put(DeviceKey.Data, mapsx);
                    dataListener.dataCallback(mapEXERCISE);
                }
                break;


        }
        //  return map;
    }
```
