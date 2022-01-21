macro "Batch FRC" {





  Dialog.create("Test");
  Dialog.addString("Directory:", "C:\_data\_storm data");
  Dialog.addCheckbox("split images ", true);
Dialog.addNumber("Windows size", 500);
Dialog.addNumber("Begin", 1);
Dialog.addNumber("End",0);
 Dialog.show();
  directory = Dialog.getString();
 doSplit= Dialog.getCheckbox();
Window_size = Dialog.getNumber();
Begin = Dialog.getNumber();
End=  Dialog.getNumber();

//add backslash if missing in dir name
//if (endsWith(directory,"\"))
//{
//	}
//	else{
//		directory=directory+"\";
//		}

// lazy renaming
if (endsWith(directory,"\ " ))
{}

else
{
	directory=directory+File.separator;
	}
dir1=directory;
dir2 = dir1;

 // read in file listing from source directory
    list = getFileList(dir1);


    // loop over the files in the source directory
    setBatchMode(true);
    for (i=0; i<list.length; i++) {
        showProgress(i+1, list.length);
	if (!endsWith(list[i], '.tif'))
        print("Not TIF: "+dir1+list[i]);
        else {
        	open(dir1+list[i]);
		name= list[i];
		index = lastIndexOf(name, "."); 
       	 	name = substring(name, 0, index);
		numstack=nSlices();
		if(numstack>100)
		{
		rename("tmp");
		  if (doSplit==true) {
		run("Split image sequence into odd and even frames");
		rename("image");
		run("Deinterleave", "how=2");
		selectWindow("image #1");
		saveAs("TIF", dir1+name+"Even Frames.tif");
		selectWindow("image #2");
		saveAs("TIF", dir1+name+"Odd Frames.tif");
		close();
		close();
		  }
		}
        }
    run("Fast Temporal Median", "Select Files = ["dir1+name+"Even Frames.tif, "+ dir1+name+"Odd Frames.tif] Window size = " + Windows_size + "Begin " + Begin + "End" + End)
	rename("image");
		run("Deinterleave", "how=2");
		selectWindow("image #1");
		saveAs("TIF", dir1+name+"Even Frames_corrected.tif");
		selectWindow("image #2");
		saveAs("TIF", dir1+name+"Odd Frames_corrected.tif");
		close();
		close();
    }
	
}
