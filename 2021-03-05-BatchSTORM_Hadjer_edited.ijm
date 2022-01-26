// This macro batch-analyzes PALM data



macro "Batch Process STORM data " { convert("Raw Data"); }

 
function convert(format) {
    requires("1.33s");

// Default values for the Options Panel
	SR_SIZE_DEF = 16;
	//ADU = 4.86 // Add real ADU 10MHz emccd gain 3
	// ADU= 1.4 - 3MHX conv gain3
	//ADU=5.5 17MHz emccd


	
// Titles of the Thunderstorm windows for catching them
	RESULTS_TITLE = "ThunderSTORM: results";
	//RECON_TITLE = "Normalized Gaussian";
RECON_TITLE = "Averaged shifted histograms";

  title = "Untitled";
  width=512; height=512;
  Dialog.create("Test");
  Dialog.addString("Directory:", "C:\_data\_storm data");
  Dialog.addCheckbox("Save .csv", true);
  Dialog.addCheckbox("STD", true);
  Dialog.addCheckbox("QuickPALM", false);
  Dialog.addCheckbox("DoM ", true);
  Dialog.addCheckbox("ThunderSTORM (Phasor)", false);
  Dialog.addCheckbox("ThunderSTORM (Gaussia)", false);
  Dialog.addCheckbox("Split frames odd/even", true);
  Dialog.addMessage("Camera Options \n") ;
Dialog.addNumber("Pixel Size", 130);
Dialog.addNumber("ADU", 0.21);
Dialog.addNumber("Noise",1);
Dialog.addNumber("BASELINE",400);
  Dialog.addMessage("Post-processing") ;
  Dialog.addNumber("Detection Threshold (AU)",300);
 Dialog.addNumber("THRESHOLD (photon)",600);
Dialog.addNumber("GROUPING_RADIUS (nm)",100);
  Dialog.addMessage("Reconstruction Settings") ;
  Dialog.addNumber("SR_Pixel Size (nm)",10);
 Dialog.show();
  directory = Dialog.getString();
  savecsv = Dialog.getCheckbox();
  doSTD = Dialog.getCheckbox();
  doQuickPALM = Dialog.getCheckbox();
 doDoM = Dialog.getCheckbox();
 doTSP= Dialog.getCheckbox();
  doTSG = Dialog.getCheckbox();
  doSplit = Dialog.getCheckbox();
PIXEL_SIZE = Dialog.getNumber();
sigma=150/PIXEL_SIZE; //do better than that
ADU = Dialog.getNumber();
NOISE=  Dialog.getNumber();
BASELINE=  Dialog.getNumber();
Det_THRESH=  Dialog.getNumber();
THRESH=  Dialog.getNumber();
GROUPING_RADIUS =  Dialog.getNumber();
SRPIXEL =  Dialog.getNumber();

MAG=PIXEL_SIZE/SRPIXEL;

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
	if (!endsWith(list[i], '.tif')){
        print("Not TIF: "+dir1+list[i]);
        }
        else {
        open(dir1+list[i]);
		name= list[i];
		index = lastIndexOf(name, "."); 
       	 	name = substring(name, 0, index);
		numstack=nSlices();
		if(numstack>100)
		{
		rename("tmp");
		run("Add...", "value = 400");
		
		if (doSplit==true) {
		dir_even = dir1+"/Even/";
		File.makeDirectory(dir_even);
		dir_odd = dir1+"/Odd/";
		File.makeDirectory(dir_odd);
		run("Split image sequence into odd and even frames");
		rename("image");
		run("Deinterleave", "how=2");
		selectWindow("image #1");
		saveAs("TIF", dir_odd+name+"\Odd.tif");
		if (doDoM==true) {
		run("Detect Molecules", "task=[Detect molecules and fit] psf="+sigma+ " intensity=4 pixel="+PIXEL_SIZE+" parallel=1000 fitting=5 ignore");
		//if (numstack>4000)
		//{
		//run("Drift Correction", "pixel=20 batch=2000 method=[Direct CC first batch and all others] apply");
		//}
		w=getWidth();
		h=getHeight();
		run("Reconstruct Image", "for=[Only true positives] pixel="+SRPIXEL+" width="+w+" height="+h+" sd=[Constant value] value=10 cut=25 x_offset=0 y_offset=0 range=1-99999 render=Z-stack z-distance=100 lut=Fire");
		selectWindow("Reconstructed Image");
		saveAs("Tiff", dir_odd+name+"_DOM.tif");
		saveAs("Results",dir_odd+name+"_DOM.xls");
		close();
		};
		rename("tmp");
		selectWindow("image #2");
		saveAs("TIF", dir_even+name+"\Even.tif");
		if (doDoM==true) {
		run("Detect Molecules", "task=[Detect molecules and fit] psf="+sigma+ " intensity=4 pixel="+PIXEL_SIZE+" parallel=1000 fitting=5 ignore");
		//if (numstack>4000)
		//{
		//run("Drift Correction", "pixel=20 batch=2000 method=[Direct CC first batch and all others] apply");
		//}
		w=getWidth();
		h=getHeight();
		run("Reconstruct Image", "for=[Only true positives] pixel="+SRPIXEL+" width="+w+" height="+h+" sd=[Constant value] value=10 cut=25 x_offset=0 y_offset=0 range=1-99999 render=Z-stack z-distance=100 lut=Fire");
		selectWindow("Reconstructed Image");
		saveAs("Tiff", dir_even+name+"_DOM.tif");
		saveAs("Results",dir_even+name+"_DOM.xls");
		close();
		};
		rename("tmp");
		//run("FRC Calculation... ", "Image 1 = "+dir1+name+"Even Frames.tif Image 2 = "+dir1+name+"Odd Frames.tif");
		close();
		close();
		//DOM pour odd et even
			}
		selectWindow("tmp");
		
		
		
		  if (doSTD==true) {
		run("Z Project...", "projection=[Standard Deviation]");
		run("Scale...", "x=2 y=2 interpolation=Bilinear create");
		saveAs("PNG", dir1+name+"_std.png");
		close();
		close();
		  }
		selectWindow("tmp");
		w=getWidth();
		h=getHeight();
		//print(w);

		
		if (doDoM==true) {
		
		run("Detect Molecules", "task=[Detect molecules and fit] psf="+sigma+ " intensity=4 pixel="+PIXEL_SIZE+" parallel=1000 fitting=5 ignore");
		//if (numstack>4000)
		//{
		//run("Drift Correction", "pixel=20 batch=2000 method=[Direct CC first batch and all others] apply");
		//}
		run("Reconstruct Image", "for=[Only true positives] pixel="+SRPIXEL+" width="+w+" height="+h+" sd=[Constant value] value=10 cut=25 x_offset=0 y_offset=0 range=1-99999 render=Z-stack z-distance=100 lut=Fire");
		selectWindow("Reconstructed Image");
		saveAs("Tiff", dir1+name+"_DOM.tif");
		saveAs("Results",dir1+name+"_DOM.xls");
		close();
		if (numstack>3000)
		{
		run("Drift Correction", "pixel=20 batch=1500 method=[Direct CC first batch and all others] apply");
		run("Reconstruct Image", "for=[Only true positives] pixel="+SRPIXEL+" width="+w+" height="+h+" sd=[Constant value] value=10 cut=25 x_offset=0 y_offset=0 range=1-99999 update render=Z-stack z-distance=100 lut=Fire");
		selectWindow("Reconstructed Image");
		saveAs("Tiff", dir1+name+"_DOM_dedrift.tif");
		saveAs("Results",dir1+name+"_DOM_dedrift.xls");
		close();
		close("Drift Correction (frames=1500 px size=20 nm)");

		run("Drift Correction", "pixel=20 batch=1500 method=[Direct CC first batch and all others] apply");
		run("Reconstruct Image", "for=[Only true positives] pixel="+SRPIXEL+" width="+w+" height="+h+" sd=[Constant value] value=10 cut=25 x_offset=0 y_offset=0 range=1-99999 average update render=Z-stack z-distance=100 lut=Fire");
		selectWindow("Reconstructed Image");
		saveAs("Tiff", dir1+name+"_DOM_dedrift_avg.tif");
		saveAs("Results",dir1+name+"_DOM_dedrift_avg.xls");
		close();
		close("Drift Correction (frames=1500 px size=20 nm)");
		}
		
		}
		if (doTSP==true) {
		run("Camera setup", "isemgain=false pixelsize=" + PIXEL_SIZE + " photons2adu=" + ADU +" quantumefficiency=0.89 offset="+BASELINE+" readoutnoise=" + NOISE);
		selectWindow("tmp");
		run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Centroid of connected components] watershed=true threshold=std(Wave.F1) estimator=[Phasor-based localisation 2D] astigmatism=false fitradius=2 calibrationpath= renderer=[Averaged shifted histograms] magnification="+MAG+" colorize=false threed=false shifts=2 repaint=500");
		run("Show results table", "action=filter formula=intensity>"+THRESH);
		//run("Show results table", "action=density neighbors=5 radius=50.0 dimensions=2D");
		
		run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] ccsmoothingbandwidth=0.25 save=false steps=10 showcorrelations=false");
		selectWindow(RECON_TITLE);
		saveAs("Tiff", dir1+name+"_TS_P.tif");
		close();
			selectWindow(RESULTS_TITLE);
			run("Export results", "floatprecision=3 filepath=["+dir1+name+"_TS_P.csv] fileformat=[CSV (comma separated)] intensity=true offset=true saveprotocol=false x=true sigma2=true y=true sigma1=true z=true bkgstd=true id=true frame=true");
		//	run("Show results table", "action=merge zcoordweight=0.1 offframes=1 dist="+GROUPING_RADIUS+" framespermolecule=0");
		//	run("Export results", "floatprecision=3 filepath=["+dir1+name+"_TS_P_GP.csv] fileformat=[CSV (comma separated)] intensity=true offset=true saveprotocol=false x=true sigma2=true y=true sigma1=true z=true bkgstd=true id=true frame=true");
			close();
		}
		if (doTSG==true) {
		run("Camera setup", "isemgain=false pixelsize=" + PIXEL_SIZE + " photons2adu=" + ADU +" quantumefficiency=0.89 offset="+BASELINE+" readoutnoise=" + NOISE);
		selectWindow("tmp");
		run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Centroid of connected components] watershed=true threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma="+sigma+" fitradius=3 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Averaged shifted histograms] magnification="+MAG+" colorize=false threed=false shifts=2 repaint=500");
		run("Show results table", "action=filter formula=intensity>"+THRESH);
		run("Show results table", "action=density neighbors=5 radius=50.0 dimensions=2D");
		
		run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] ccsmoothingbandwidth=0.25 save=false steps=10 showcorrelations=false");
		selectWindow(RECON_TITLE);
		saveAs("Tiff", dir1+name+"_TS_G.tif");
		close();
			selectWindow(RESULTS_TITLE);
			run("Export results", "floatprecision=3 filepath=["+dir1+name+"_TS_G.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true");
			run("Show results table", "action=merge zcoordweight=0.1 offframes=1 dist="+GROUPING_RADIUS+" framespermolecule=0");
			run("Export results", "floatprecision=3 filepath=["+dir1+name+"_TS_G_GP.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true detections=true");
			close();
		}
		

		if (doQuickPALM==true) {
		selectWindow("tmp");
		run("Analyse Particles", "minimum=3 maximum=4 image=160 smart online stream file=D:\\test.xls pixel=30 accumulate=0 update=100 _image=imgNNNNNNNNN.tif start=0 in=50 _minimum=50 local=20 _maximum=1000 threads=50");
		run("16-bit");
		run("Multiply...", "value=3.000");
		run("Smooth");
		run("Scale Bar...", "width=1000 height=4 font=14 color=White background=None location=[Lower Right] bold");
		saveAs("Tiff", dir1+name+"_QkPALM.tif");
		close(); 
		close();
		open("D:\\test.xls");
		saveAs("Results",dir1+name+".xls");
		}
		run("Close All");
		close("Drift*");
		close("*.csv");
		close("\\Others");
		 close("Histo*"); 
		 close("*");
		}
		else 
		close();
  	  }
	}
}





