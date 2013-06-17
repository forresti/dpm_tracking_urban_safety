<h4><code>dpm_tracking_urban_safety</code></h4>
<h3>Measuring urban traffic safety by tracking Deformable Parts Models</h3>




Getting started:
<pre>open a Matlab prompt
<b>compile_voc_release5</b> #only need to do this the 1st time.
<b>demo_sensys_dataset</b> #detect cars in Dir_2_Lane_3_285

see the images with the detected car bounding boxes in Dir_2_Lane_3_285_detections
look in <b>detectionDetails.mat</b> for the HOG features from the detected image and the HOGs from the DPM model
</pre>

Directory structure:
<pre>voc-release5 -- off-the-shelf Deformable Parts Model (DPM) code by Girshick, R. B. and Felzenszwalb, P. F. and McAllester, D.
sensys_models -- car model trained on Sensys urban traffic dataset
auxiliary_forTracking -- additional hooks into voc-release5 for tracking 
</pre>


Output data structure:
``` matlab 
detectionDetails.mat
  detectionDetails(detectionIdx).bbox %1x4 array: x1, y1, x2, y2
  detectionDetails(detectionIdx).bbox_id %index of the detected bounding box within current image.
  detectionDetails(detectionIdx).bbox_hog_descriptor %HOG features extracted from the detected bounding box
  detectionDetails(detectionIdx).dpm_hog_descriptor %DPM model's root filter used in this detection
  detectionDetails(detectionIdx).dpm_orientation_id %which DPM component (submodel) was used?
  detectionDetails(detectionIdx).img_id %Each image has a unique int ID number, starting from 1 (in time-series order). 
  detectionDetails(detectionIdx).img_name
```


