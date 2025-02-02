function scr_init() {
	gridwidth = 360*GRIDSIZE;
	gridheight = 180*GRIDSIZE;
	scale = 4/GRIDSIZE; //grids per lat degree
	
	monthtext[0] = "January"
	monthtext[1] = "February"
	monthtext[2] = "March"
	monthtext[3] = "April"
	monthtext[4] = "May"
	monthtext[5] = "June"
	monthtext[6] = "July"
	monthtext[7] = "August"
	monthtext[8] = "September"
	monthtext[9] = "October"
	monthtext[10] = "November"
	monthtext[11] = "December"

	//Reference latitudes
	equator = gridheight*0.5;
	//arctic = equator-60*scale;
	//horselatitude = equator-30*scale;
	//temperate = equator-40*scale;

	//Reference delta latitudes
	tilt = 23*scale;
	ITCZoffset = 5*scale;

	//Reference heights (m)
	highlevel = 600;
	shelf = -200;
	ocean = -4000;
	deep = -6000;

	//Humidity bands
	aridH = 12;
	semiaridH = 30;
	semihumidH = 60;
	humidH = 95;
	
	//Height map colors
	c_0 = make_color_rgb(120,205,203); // less than 0m
	c_1 = make_color_rgb(120,119,243); // less than 64m
	c_2 = make_color_rgb(184,119,203); // less than 124m
	c_3 = make_color_rgb(206,122,203); // less than 183m
	c_4 = make_color_rgb(207,119,180); // less than 259m
	c_5 = make_color_rgb(247,119,116); // less than 342m
	c_6 = make_color_rgb(248,151,116); // less than 441m
	c_7 = make_color_rgb(248,183,116); // less than 573m
	c_8 = make_color_rgb(248,214,116); // less than 784m
	c_9 = make_color_rgb(248,247,117); // less than 1092m
	c_10 = make_color_rgb(120,247,117); // less than 1602m
	c_11 = make_color_rgb(138,229,116); // at least 1602m
	
	//Biome map colors
	c_trosav = make_color_rgb(207,201,53); 
	c_trodec = make_color_rgb(99,119,69); 
	c_trorai = make_color_rgb(10,40,11);
	c_troste = make_color_rgb(141,111,28); 
	c_stewoo = make_color_rgb(127,82,26); 
	c_stepra = make_color_rgb(170,202,93); 
	c_talgra = make_color_rgb(151,157,60); 
	c_des = make_color_rgb(244,212,111); 
	c_deswoo = make_color_rgb(129,129,34); 
	c_medwoo = make_color_rgb(101,128,33); 
	c_medscru = make_color_rgb(225,134,71); 
	c_gar = make_color_rgb(98,142,92); 
	c_medcoa = make_color_rgb(227,166,75); 
	c_wescoa = make_color_rgb(49,151,103);
	c_subfor = make_color_rgb(37,68,0);
	c_tembro = make_color_rgb(64,171,43); 
	c_subcon = make_color_rgb(31,103,30); 
	c_hea = make_color_rgb(229,166,236); 
	c_tai = make_color_rgb(33,121,107); 
	c_tun = make_color_rgb(158,126,187); 
	c_iceshe = make_color_rgb(135,135,135); 
	c_oce = make_color_rgb(27,46,68);

	//Real colors
	c_shallow = make_colour_rgb(78,97,156);
	c_deep = make_colour_rgb(17,30,68);
	c_icesheet = make_colour_rgb(237,232,228);

	c_coldscrub = make_colour_rgb(224,198,175);
	c_warmscrub = make_colour_rgb(242,211,169);
	c_hotscrub = make_colour_rgb(252,228,176);
	c_sand = make_colour_rgb(255,242,198);
	c_rock = make_colour_rgb(168,165,161);
	c_rock_h = colour_get_hue(c_rock);
	c_rock_s = colour_get_saturation(c_rock);
	c_rock_v = colour_get_value(c_rock);
        
	c_coldgrass = make_colour_rgb(75,66,49);
	c_coldgrassa = make_colour_rgb(86,74,60);
	c_warmgrass = make_colour_rgb(89,87,64);
	c_warmgrassa = make_colour_rgb(196,164,125);
	c_hotgrass = make_colour_rgb(135,119,89);
	c_hotgrassa = make_colour_rgb(184,146,108);

	c_coldwood = make_colour_rgb(50,54,39);
	c_coldwooda = make_colour_rgb(71,69,44);
	c_warmwood = make_colour_rgb(56,68,46);
	c_warmwooda = make_colour_rgb(69,69,51);
	c_hotwood = make_colour_rgb(51,63,45);
	c_hotwooda = make_colour_rgb(87,82,52);

	c_coldforest = make_colour_rgb(42,46,31);
	c_coldforesta = make_colour_rgb(47,50,38);
	c_warmforest = make_colour_rgb(40,53,34);
	c_warmforesta = make_colour_rgb(49,56,45);
	c_hotforest = make_colour_rgb(33,50,33);
	c_hotforesta = make_colour_rgb(46,54,38);

	c_river = make_colour_rgb(83,106,160);

	//init arrays
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        noise_x[i,j] = 0;
	        noise_y[i,j] = 0;
	        noise_cos[i,j] = 0;
	        noise_sin[i,j] = 0;
			platelist[i,j] = 0;
			platecolor[i,j] = 0;
			platedir[i,j] = 0;
			plateid[i,j] = 0;
	        world[i,j] = 0;
	        worldslope[i,j] = 0;
	        worldangle[i,j] = 0;
	        worldref[i,j] = 0;
	        worldrefx[i,j] = 0;
	        worldrefy[i,j] = 0;
	        worldrefslope[i,j] = 0;
	        worldrefangle[i,j] = 0;
			coast[i,j] = 0;
	        mountains[i,j] = 0;
			highlands[i,j] = 0;
	        relief[i,j] = 0;
	        current_s[i,j] = 0;
	        current_w[i,j] = 0;
			currentdirection_s[i,j] = 0;
			currentdirection_w[i,j] = 0;
			climate_s[i,j] = 0;
	        climate_w[i,j] = 0;
	        coldspot[i,j] = 0;
	        hotspot[i,j] = 0;
	        koppen[i,j] = "";
			koppentype[i,j] = "";
	        koppencolor[i,j] = "c_white";
	        river[i,j] = 0;
	        biomes[i,j] = "null";
			biomesmap[i,j] = c_white;
	        biomescolor[i,j] = c_white;
			
			tempgraphmax[i,j] = 0;
			tempgraphmin[i,j] = 0;
			tempgraphmean[i,j] = 0;
			raingraphmax[i,j] = 0;
			raingraphmean[i,j] = 0;
			
			
			for (var m = 0; m < 12; m++) {
				
				currentmonth[m][i][j] = 0;
				currentmapmonth[m][i][j] = 0;
				pressuremonth[m][i][j] = 0;
				pressuredmonth[m][i][j] = 0;
				pressurebandmonth[m][i][j] = 0;
				windamonth[m][i][j] = 0;
				windxmonth[m][i][j] = 0;
				windymonth[m][i][j] = 0;
				climatemonth[m][i][j] = 0;
				temperaturebandmonth[m][i][j] = 0;
				humiditymonth[m][i][j] = 0;
				humiditybandmonth[m][i][j] = 0;
				rainlevelmonth[m][i][j] = 0;
				rainmonth[m][i][j] = 0;
				PETmonth[m][i][j] = 0;
				ariditymonth[m][i][j] = 0;
				tempgraphmonth[m][i][j] = 0;
				raingraphmonth[m][i][j] = 0;
			}
	        }
	    }    
    
    
	for (var i = 0; i < gridwidth; i ++) {
	    ITCZ_s[i] = 0;
	    ITCZ_w[i] = 0;
	    northPF_s[i] = 0;
	    northPF_w[i] = 0;
	    southPF_s[i] = 0;
	    southPF_w[i] = 0;
	    northSH_s[i] = 0;
	    northSH_w[i] = 0;
	    southSH_w[i] = 0;
	    southSH_s[i] = 0;
		for (var m = 0; m < 12; m++) {
			ITCZmonth[m,i] = 0;
			northPFmonth[m,i] = 0;
			southPFmonth[m,i] = 0;
			northSHmonth[m,i] = 0;
			southSHmonth[m,i] = 0;
			}
	    }

	culture[0,0] = 0;
    
	//1D 7 unit gaussian blur kernel
	gauss1D[0] = 0.0365; gauss1D[1] = 0.1095; gauss1D[2] = 0.2153; gauss1D[3] = 0.2774; gauss1D[4] = 0.2153; gauss1D[5] = 0.1095; gauss1D[6] = 0.0365;
	
	//7x7 gaussian blur kernel (OBSOLETE?)
	gauss[0,0] = 0.001; gauss[1,0] = 0.004; gauss[2,0] = 0.008; gauss[3,0] = 0.010; gauss[4,0] = 0.008; gauss[5,0] = 0.004; gauss[6,0] = 0.001; //0.036
	gauss[0,1] = 0.004; gauss[1,1] = 0.012; gauss[2,1] = 0.024; gauss[3,1] = 0.030; gauss[4,1] = 0.024; gauss[5,1] = 0.012; gauss[6,1] = 0.004; //0.110
	gauss[0,2] = 0.008; gauss[1,2] = 0.024; gauss[2,2] = 0.047; gauss[3,2] = 0.059; gauss[4,2] = 0.047; gauss[5,2] = 0.024; gauss[6,2] = 0.008; //0.217
	gauss[0,3] = 0.010; gauss[1,3] = 0.030; gauss[2,3] = 0.059; gauss[3,3] = 0.076; gauss[4,3] = 0.059; gauss[5,3] = 0.030; gauss[6,3] = 0.010; //0.271
	gauss[0,4] = 0.008; gauss[1,4] = 0.024; gauss[2,4] = 0.047; gauss[3,4] = 0.059; gauss[4,4] = 0.047; gauss[5,4] = 0.024; gauss[6,4] = 0.008; //0.217
	gauss[0,5] = 0.004; gauss[1,5] = 0.012; gauss[2,5] = 0.024; gauss[3,5] = 0.030; gauss[4,5] = 0.024; gauss[5,5] = 0.012; gauss[6,5] = 0.004; //0.110
	gauss[0,6] = 0.001; gauss[1,6] = 0.004; gauss[2,6] = 0.008; gauss[3,6] = 0.010; gauss[4,6] = 0.008; gauss[5,6] = 0.004; gauss[6,6] = 0.001; //0.036
	
	//1D 31 unit gaussian blur kernel
	var total = 0;
	var r = 21;
	var d = 0.5*(r-1);
	for (var g = 0; g < r; g++) {
		var X = (g-d)/d;
		gauss21[g] = exp(-sqr(1.5*X));
		total += gauss21[g];
		}
	for (var g = 0; g < r; g++) {
		gauss21[g] = gauss21[g]/total;
		}
		
	//1D 13 unit gaussian blur kernel
	var total = 0;
	var r = 13;
	var d = 0.5*(r-1);
	for (var g = 0; g < r; g++) {
		var X = (g-d)/d;
		gauss13[g] = exp(-sqr(1.5*X));
		total += gauss13[g];
		}
	for (var g = 0; g < r; g++) {
		gauss13[g] = gauss13[g]/total;
		}

}
