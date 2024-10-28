@isTest
global class MockGetConfigClass implements HttpCalloutMock{

  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"config": {"desired": {"network": {"period": 7200},"temperature": {"enabled": false,"sampling_period": 7200},"accelerometer": {"tracking": {"locations_per_checkin": 1,"lower_accel_threshold": 50,"inactivity_before_movement_end": 900,"bucket_fill_time": 50,"connect_on_movement_start": false,"connect_on_movement_end": false,"location_period": 7200,"bucket_size": 100},"enabled": false,"mode": 2},"location": {"useGPS": false,"useCell": true,"useWiFi": false,"enabled": true,"sampling_period": 900}},"reported": {"network": {"period": 7200},"accelerometer": {"tilt": {"reference_y": 0,"reference_x": 0,"reference_z": 0,"log_every_n": 0,"degrees": 15,"connect_on_tilt": false},"measurement_period": 15,"tracking": {"locations_per_checkin": 1,"lower_accel_threshold": 50,"inactivity_before_movement_end": 900,"bucket_fill_time": 50,"connect_on_movement_start": false,"connect_on_movement_end": false,"location_period": 7200,"bucket_size": 100},"enabled": false,"mode": 2},"location": {"useCell": true,"useWiFi": false,"enabled": true,"sampling_period": 900},"ble": {"enabled": false,"sampling_period": 15,"scan_duration": 6},"temperature": {"sampling_period": 7200,"high1": 22,"high2": 23,"enabled": false,"low2": 19,"low1": 20,"alert_connect_mask": 0,"log_every_n_samples": 1}}},"deviceId": "at5-t16ee4491f50"}');
    return res;
  }
}