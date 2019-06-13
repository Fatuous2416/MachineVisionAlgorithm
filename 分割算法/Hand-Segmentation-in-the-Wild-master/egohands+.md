To study fine-level action recognition, we labeled a subset of video frames from [Egohands](http://vision.soic.indiana.edu/projects/egohands/) dataset at hand-level. 
We annotated a small subset of 8 videos (800 frames),
2 from each coarse-level activity for outdoors (courtyard) in
the EgoHands dataset at hand-pose level. We labeled each
hand pose with one of the following 16 activities: **holding,
picking, placing, resting, moving, replacing, thinking,
pulling, pushing, stacking, adjusting, matching, pressing,
highfive, pointing,** and **catching**. Ambiguous hand poses
are annotated with multiple possible labels(e.g., picking and
placing are sometimes difficult to be inferred at a single
frame-level).

![EgoHands+](images/egohands+.png) 

We have annotated hands with action labels in two settings: 
* coarse hand maps: where we just outlined the hand boundaries
* fine hand maps: where we take extra care to outline details about fingers as much as possible.

We used [LabelMe](http://labelme.csail.mit.edu/Release3.0/) for annotations. Annotation files are in .xml format and we provide matlab scripts(based on labelme-toolbox api) to parse these annotations and generate hand masks. However, one can easily write his/her own script using LabelMe toolbox to manipulate these annotations as per their need. 

Each "hand" object is labeled with attributes in the following format: 

'hand_type,actions,object,subject'

* 'hand_type' is which hand it is ('left' or 'right'), respective to the person the hand belongs to
* 'actions' is all of the actions it looks like the hand is doing based on that single frame. If it's an ambiguous action, we annotate it with multiple possible actions, separated with commas. Ex:
  * 1 action:    left,picking,cards,other
  * 2 actions:  left,picking,placing,cards,other
* 'object' is one of these 4 objects:
  * cards
  * jenga_block
  * chess_piece
  * puzzle_piece
  
If the hand is not manipulating any objects, we simply put an underscore '_' separated by commas. Ex:
left,resting,_,first_person
* 'subject' is either 'first_person' or 'other'

Each "object" is labeled and named as one of the following:
  * cards
  * jenga_block
  * chess_piece
  * puzzle_piece

In the attributes, we labeled who is manipulating the object (either 'first_person' or 'other'). If they are both manipulating the same object, we just put both separated by a comma ('first_person,other')

## Usage
1. Install LabelMe MATLAB toolbox as instructed [here](http://labelme2.csail.mit.edu/Release3.0/browserTools/php/matlab_toolbox.php).
2. Download [EgoHands+](https://1drv.ms/u/s!AtxSFigVVA5JhNtsRdvgmxvB2c1rPg).
3. We have borrowed some code from EgoHands dataset's [page](http://vision.soic.indiana.edu/projects/egohands/) already uploaded here. For their complete API you can refer to the original project. 
4. Place our matlab_scripts in the labelme toolbox folder.
5. Setup paths for the directory with EgoHands+ dataset and destination directory.
6. Run ```load_generate_gt_imgs_hands_objects2.m``` to generate masks for hands+objects setup. This would also generate a text file with images along with their labels.
7. Run ```load_generate_gt_imgs_objects_only.m``` to generate masks for objects only setup.
8. Run ```load_generate_gt_imgs2.m``` to generate masks for hands only setup.

