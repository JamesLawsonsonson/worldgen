function scr_generate(argument0) {
	force_continue = 0;

	if step = 0 {

	if substep = 0 {

	//Generate noise maps
	seed = argument0;
	var ds = floor(seed/4295098369);
	var dt = floor(ds/4295098369);
	var value = LCG(seed);
	var value2 = LCG(floor(seed*1.00001525879));
	Ox = LCG(dt)/65537;
	Oy = LCG(dt+ds+value+value2)/65537;
	
	for (var i = 0; i <= gridwidth; i ++) {
	    for (var j = 0; j <= gridheight; j ++) {
			var ii = (i+ds)mod(gridwidth+1);
			var jj = (j+dt)mod(gridheight+1);
			value = LCG(value);
	        noise_x[ii,jj] = clamp(2*value/65537-1,-1,1);
		}
	}
	for (var i = 0; i <= gridwidth; i ++) {
	    for (var j = 0; j <= gridheight; j ++) {
			var ii = (i+ds)mod(gridwidth+1);
			var jj = (j+dt)mod(gridheight+1);
	        value2 = LCG(value2);
	        noise_y[ii,jj] = clamp(2*value2/65537-1,-1,1);
	        var A = point_direction(0,0,noise_x[i,jj],noise_y[ii,j])+dt*0.173;
	        noise_cos[ii,jj] = -lengthdir_x(1,A);
	        noise_sin[ii,jj] = lengthdir_y(1,A);
	        }
	    }
	for (var i = 0; i <= gridwidth; i ++) {
		noise_cos[i,gridheight] = noise_cos[i,0];
	    noise_sin[i,gridheight] = noise_sin[i,0];
		}
	for (var j = 0; j <= gridheight; j ++) {
		noise_cos[gridwidth,j] = noise_cos[0,j];
	    noise_sin[gridwidth,j] = noise_sin[0,j];
		}
		
	for (var i = 0; i <= gridwidth; i ++) {
	    for (var j = 0; j <= gridheight; j ++) {
			noise_smooth1[i,j] = noise_x[i*0.5,j*0.5]+noise_x[i*0.25+45,j*0.25+123]+noise_x[i*0.125+45,j*0.125+123]+noise_x[i*0.0625+145,j*0.0625+23]+noise_x[i*0.03125+23,j*0.03125+45];
			noise_smooth2[i,j] = noise_y[i*0.5,j*0.5]+noise_y[i*0.25+45,j*0.25+123]+noise_y[i*0.125+45,j*0.125+123]+noise_y[i*0.0625+145,j*0.0625+23]+noise_y[i*0.03125+23,j*0.03125+45];
		}
	}
	
	for (var i = 0; i <= gridwidth; i ++) {
	    for (var j = 0; j <= gridheight; j ++) {
	            var X1 = 0;
				var X2 = 0;
	            for (var g = -10; g < 11; g ++) {
					var ii = (i+g+gridwidth+1) mod (gridwidth+1)
	                X1 += noise_smooth1[ii,j]*gauss21[g+10];
					X2 += noise_smooth2[ii,j]*gauss21[g+10];
	                }
	            noise_smooth1A[i,j] = X1;
	            noise_smooth2A[i,j] = X2;
	        }
	    }
	for (var i = 0; i <= gridwidth; i ++) {
	    for (var j = 0; j <= gridheight; j ++) {
	            var X1 = 0;
				var X2 = 0;
	            for (var g = -10; g < 11; g ++) {
	                X1 += noise_smooth1A[i,clamp(j+g,0,gridheight)]*gauss21[g+10];
					X1 += noise_smooth2A[i,clamp(j+g,0,gridheight)]*gauss21[g+10];
	                }
	            noise_smooth1[i,j] = 10*X1;
	            noise_smooth2[i,j] = 10*X2;
	        }
	    }
		
	noise_smooth1A = 0;
	noise_smooth2A = 0;
	
	message = "Generating plates..."
	alarm[0]=2;
	}

	if substep = 1 {

	
	maxheight = 0;
	
	//Create plate seed points
	
	var n = 75; //number of plates
	var amplitude = 900; //max height (m)
	var land = 0.35; //land percentage (0-1)
	var northpole = -1; //north pole force land (1) or ocean (-1)
	var southpole = 1; //south pole force land (1) or ocean (-1)
	
	var poleA = sign(southpole-northpole);
	var On = (n-2)*(1-land)+2;
	var px = LCG((Oy+3*noise_x[1,2]+6)*16709.7+LCG(seed)*0.002);
	var py = LCG(px*6969+Ox);
	var ph = LCG(py*0.69);
	var pd = LCG(ph+2);
	
	for (var p = 0; p < n; p ++) {
		
		//longitude
		var xx = (px/65537)-(p mod 2);
		platelist[p,0] = xx*320+360; 
		
		//latitude, bias points towards equator to account for map projection distortion
		var yy = 2*py/65537-1;
		platelist[p,1] = sign(yy)*power(abs(yy),1.25)*100+180;  
		
		//height
		platelist[p,2] = ph/65537*amplitude; 
		
		//north/south pole adjustment
		if p = 0 {platelist[p,0] = 360; platelist[p,1] = 0; platelist[p,2] = abs(platelist[p,2])*northpole}
		if p = 1 {platelist[p,0] = 360; platelist[p,1] = gridheight-1; platelist[p,2] = abs(platelist[p,2])*southpole}
		if p < On && p > 1 {platelist[p,2] = -platelist[p,2]; platelist[p,1] = (platelist[p,1]-equator)*(1+0.1*abs(poleA)) + equator + poleA*10}
		if p >= On {platelist[p,1] = (platelist[p,1]-equator)*(1+0.1*abs(poleA)) + equator - poleA*10}
		
		//force ocean at edges
		if p = 2 {platelist[p,0] = 0}//; platelist[p,1] = equator+60}
		if p = 3 {platelist[p,0] = 0}//; platelist[p,1] = equator-60}
		
		//slightly lower ocean plates
		if platelist[p,2] <= 0 {platelist[p,2] -= 80}
		
		//direction (for mountains)
		platelist[p,3] = 360*pd/65537; 
		
		//randomize
		px = LCG(px*1.1);
		py = LCG(py*1.01);
		ph = LCG(ph*1.001);
		pd = LCG(pd+6);
		}
		
	//Generate plates via voronoi tessellation
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			var dist = 99999999;
			var N = 0;
			var edgecut = 1-clamp(abs(i-360) - 340, 0, 20)*0.05
			var ii = i+noise_x[i*0.3,j*0.3]+noise_y[40+i*0.17,49+j*0.17]*1.8+noise_x[32+i*0.11,4+j*0.11]*3.09*0+noise_y[10+i*0.07,18+j*0.07]*5.20*0+noise_x[9+i*0.041,52+j*0.041]*4.86*0+noise_smooth1[i,j]+terrain(7,0.2,0.8,10*edgecut,0,-1,0,0,i,j);;//+terrain(32,0.1,0.1,6*edgecut,0,-0.2,0,0,i,j)+terrain(16,0.5,0.7,8*edgecut,0,-0.2,0,0,i,j)+terrain(11,0.4,0.1,7*edgecut,0,-1,0,0,i,j)+terrain(7,0.2,0.8,10*edgecut,0,-1,0,0,i,j);//+terrain(5,0.5454,0.4545,10*edgecut,0,-1,0,0,i,j); //+terrain(128,0.2,0.3,2,0,-0.2,0,0,i,j)+terrain(64,0.8,0.2,4,0,-0.2,0,0,i,j)
			var jj = j+noise_y[i*0.3,j*0.3]+noise_x[40+i*0.17,49+j*0.17]*1.8+noise_y[32+i*0.11,4+j*0.11]*3.09*0+noise_x[10+i*0.07,18+j*0.07]*5.20*0+noise_y[9+i*0.041,52+j*0.041]*4.86*0+noise_smooth2[i,j]+terrain(7,0.8,0.7,10*edgecut,0,-1,0,0,i,j);;//+terrain(32,0.4,0.6,6*edgecut,0,-0.2,0,0,i,j)+terrain(16,0.3,0.3,8*edgecut,0,-0.2,0,0,i,j)+terrain(11,0.5,0.1,7*edgecut,0,-1,0,0,i,j)+terrain(7,0.8,0.7,10*edgecut,0,-1,0,0,i,j);//+terrain(5,0.1616,0.6161,10*edgecut,0,-1,0,0,i,j); //+terrain(128,0.7,0.3,2,0,-0.2,0,0,i,j)+terrain(64,0.1,0.4,4,0,-0.2,0,0,i,j)
			for (var p = 0; p < n; p ++) {
				var xx = platelist[p,0];
				var yy = platelist[p,1];
				var A = 1-clamp(abs(equator-mean(jj,yy))/180,0,1);
				var AA = sin(pi*0.5*A);
				var dx = min(abs(ii - xx), abs(ii - xx + gridwidth-1), abs(ii - xx - gridwidth-1))*AA;
				var dy = abs(jj - yy);
				var d = dx*dx+dy*dy;
				if d < dist {
					N = p;
					dist = d;
					}
				}
			world[i,j] = platelist[N,2];
			platedir[i,j] = platelist[N,3];
			plateid[i,j] = N;
			}
	    }
	
	//plate boundary unique colors (for visualization)
	var colors = 12;
	var h_step = floor(256/colors);
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
				var N = plateid[i,j];
				var check = 0;
				var il = max(0,i-1);
				var ir = min(gridwidth-1,i+1);
				var ju = max(0,j-1);
				var jd = min(gridheight-1,j+1);
				if plateid[il,j] != N || plateid[ir,j] != N || plateid[i,ju] != N || plateid[i,jd] != N  {check = 1}
				
				if check = 1 {
					var NN = N mod colors
					var NNN = floor(N/colors);
					var hue = NN*h_step;
					var sat = min(255,NNN*32 + 128);
					var val = min(255,256+128-NNN*32);
					platecolor[i,j] = make_color_hsv(hue,sat,val);
					}
	            
	        }
	    }
	
	//Blend terrain
	var A = 3;
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	            var X = 0;
	            for (var g = -10; g < 11; g ++) {
					var ii = (i+g*A+gridwidth) mod (gridwidth)
	                X += world[ii,j]*gauss21[g+10];
	                }
	            worldref[i,j] = X;
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	            var X = 0;
	            for (var g = -10; g < 11; g ++) {
	                X += worldref[i,clamp(j+g*A,0,gridheight-1)]*gauss21[g+10];
	                }
	            world[i,j] = lerp(world[i,j],X,0.5);
	        }
	    }
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	            var X = 0;
	            for (var g = -3; g < 4; g ++) {
					var ii = (i+g+gridwidth) mod (gridwidth)
	                X += world[ii,j]*gauss1D[g+3];
	                }
	            worldref[i,j] = X;
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	            var X = 0;
	            for (var g = -3; g < 4; g ++) {
	                X += worldref[i,clamp(j+g,0,gridheight-1)]*gauss1D[g+3];
	                }
	            world[i,j] = X;
	        }
	    }
	
	worldref = 0;
	
		
	message = "Building terrain..."
	alarm[0]=2;
	}

	if substep = 2 {
	maxheight = 0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
			world[i,j] += terrain(6.59,Ox+0.43215,Oy+0.32952,910*A,0,0.5,0,0,i,j);
			world[ii,j] += terrain(6.59,Ox-0.43215,Oy-0.32952,910*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}

	if substep = 3 {
	maxheight = 0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(9.82,Ox+0.31038,Oy-0.70256,611*A,0,0.5,0,0,i,j);
	        world[ii,j] += terrain(9.82,Ox-0.31038,Oy+0.70256,611*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}

	if substep = 4 {      
	maxheight = 0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(14.61,Ox-0.43207,Oy-0.59810,411*A,0,0.5,0,0,i,j);
	        world[ii,j] += terrain(14.61,Ox+0.43207,Oy+0.59810,411*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}

	if substep = 5 {    
	maxheight = 0;  
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(21.74,Ox-0.42910,Oy-0.90807,276*A,0,0.5,0,0,i,j);
	        world[ii,j] += terrain(21.74,Ox+0.42910,Oy+0.90807,276*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}

	if substep = 6 {
	maxheight=0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
			world[i,j] += terrain(32.36,Ox-0.50062,Oy-0.81023,185*A,0,0.5,0,0,i,j);
			world[ii,j] += terrain(32.36,Ox+0.50062,Oy+0.81023,185*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}

	if substep = 7 {      
	maxheight=0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(48.17,Ox+0.98467,Oy-0.64516,125*A,0,0.5,0,0,i,j);
	        world[ii,j] += terrain(48.17,Ox-0.98467,Oy+0.64516,125*A,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}
	
	if substep = 8 {      
	maxheight=0;
	for (var i = 0; i < gridwidth; i ++) {
		var A = 1-clamp(abs(i - 360)/360,0,1);
		var ii = (i+360) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(71.69,Ox+0.28904,Oy-0.11202,84,0,0.5,0,0,i,j);
	        world[ii,j] += terrain(71.69,Ox-0.28904,Oy+0.11202,84,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
   
	alarm[0]=2;
	}
	
	if substep = 9 {    
	maxheight=0;  
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        world[i,j] += terrain(102.71,Ox,Oy,56,0,0.5,0,0,i,j);
	        world[i,j] += terrain(120.17,Ox,Oy,46,0,0.5,0,0,i,j);
	        world[i,j] += terrain(140.60,Ox,Oy,38,0,0.5,0,0,i,j);
	        maxheight = max(maxheight,world[i,j]);
	        }
	    }
	
	mapmode = 0;

	message = "Adjusting base terrain..."    
	alarm[0]=2;
	}

	if substep = 10 {

	
    
	//lat/long average height reference
	latA[0] = 0;
	longA[0] = 0;
	var north = 0;
	var south = 0;
	for (var k = 0; k < max(gridheight,gridwidth)+10; k++) {latA[k] = 0; longA[k] = 0}

	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			if world[i,j] > 0 {
				if j < equator && j > equator - 180 {north += 1}
				if j > equator && j < equator + 180 {south += 1}
				}
	        latA[j] += world[i,j]/gridheight;
	        longA[i] += world[i,j]/gridwidth;  
	        }
	    }

	//stretch poles
	var N = latA[0]; var S = latA[gridheight-1];
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < equator-120; j++) {
	        var jj = sqr(sqr(clamp((60-j)/60,0,1)));
	        world[i,j] = lerp(world[i,j],N,jj);
	        }
	    for (var j = gridheight-1; j > equator+120; j--) {
	        var t = 2*equator-j;
	        var jj = sqr(sqr(clamp((60-t)/60,0,1)));
	        world[i,j] = lerp(world[i,j],S,jj);
	        }
	    }
	
	
	
	//make edges ocean + sink ocean
	var k = deep - shelf;
	
	for (var i = 0; i < gridwidth; i ++) {
	    var X = abs(i-(gridwidth-1)*0.5)/(gridwidth-1)*3-1;
	    for (var j = 0; j < gridheight; j ++) {
	        var Y = 1-abs(j-equator)/160;
	        var A = clamp(X*Y,0,1);
			var B = (world[i,j]+1500)*0.5-1500
	        world[i,j] = lerp(world[i,j],B,A)
			if world[i,j] <= 0 {world[i,j] = 1.25*world[i,j]}
	        if world[i,j] < shelf {
	            var C = (world[i,j] - shelf)*2;
	            var D = power(abs(C/k),0.71);
	            worldref[i,j] = -abs(k*D);
	            }
	        else {
	            worldref[i,j] = world[i,j];
	            }
	        world[i,j] = worldref[i,j];
	        
	        }
	   }

	//flatten land
	maxheight=0;
	for (var j = 0; j < gridheight; j ++) {
	    for (var i = 0; i < gridwidth; i ++) {
			if world[i,j] <= 0 {
				worldref[i,j] = world[i,j];
				}
			else {
				worldref[i,j] = world[i,j]*0.3;
				}
			world[i,j] = worldref[i,j];
			maxheight = max(maxheight,world[i,j]);
	        }
	    }
    



	message = "Simulating mountain formation..."
	alarm[0]=2;
	}
	}

	if step = 1 {
	
	//plate collision
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			var me = plateid[i,j];
			var X = 0;
			for (var s = -2; s <= 2; s ++) {
				for (var t = -2; t <= 2; t ++) {
					var ii = (i-s+gridwidth) mod (gridwidth)
					var jj = clamp(j+t,0,gridheight-1);
					var you = plateid[ii,jj]
					var oceancheck = 0;
					if platelist[me,2] < 0 || platelist[you,2] < 0 {oceancheck = 0.7}
					var c = (1-lengthdir_x(1,platedir[ii,jj]-platedir[i,j]))*0.5;
					var d = point_direction(i,j,i+s,jj);
					var dd = lengthdir_x(1,angle_difference(d,platedir[i,j]));
					var a = dd;
					if a < 0 {a = -0.5*a}
					X = max(X,abs(c*a)-oceancheck,0);
					}
				}
			mountains[i,j] = X;
			}
		}

	

	//Blend mountain peak influence  
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var ii = (i+g + gridwidth) mod gridwidth;
	            X += mountains[ii,j]*gauss1D[g+3];
	            }
	        mountainsA[i,j] = abs(X);
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var jj = clamp(j+g,0,gridheight-1);
	            X += mountainsA[i,jj]*gauss1D[g+3];
	            }
	        mountains[i,j] = abs(X);
	        }
	    }
		
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var ii = (i+g + gridwidth) mod gridwidth;
	            X += mountains[ii,j]*gauss1D[g+3];
	            }
	        mountainsA[i,j] = abs(X);
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var jj = clamp(j+g,0,gridheight-1);
	            X += mountainsA[i,jj]*gauss1D[g+3];
	            }
	        mountains[i,j] = abs(X);
	        }
	    }
	mountainsA = 0;
    
	
	//Blend mountain base influence
	highlandsA[0,0] = 0;
	
	var A = 2;
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var ii = (i+g*A + gridwidth) mod gridwidth;
	            X += mountains[ii,j]*gauss1D[g+3];
	            }
	        highlandsA[i,j] = X;
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var jj = clamp(j+g*A,0,gridheight-1);
	            X += highlandsA[i,jj]*gauss1D[g+3];
	            }
	        highlands[i,j] = abs(X)*3;
	        }
	    }	
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -10; g < 11; g ++) {
				var ii = (i+g*A + gridwidth) mod gridwidth;
	            X += mountains[ii,j]*gauss21[g+10];
	            }
	        highlandsA[i,j] = X;
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -10; g < 11; g ++) {
				var jj = clamp(j+g*A,0,gridheight-1);
	            X += highlandsA[i,jj]*gauss21[g+10];
	            }
	        highlands[i,j] = sqrt(abs(X));
	        }
	    }
		
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var ii = (i+g + gridwidth) mod gridwidth;
	            X += mountains[ii,j]*gauss1D[g+3];
	            }
	        highlandsA[i,j] = X;
	        }
	    }
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -3; g < 4; g ++) {
				var jj = clamp(j+g,0,gridheight-1);
	            X += highlandsA[i,jj]*gauss1D[g+3];
	            }
	        var K = 1-clamp(abs(equator-j)/60,0,1);
			X = power(X,K+1);
	        highlands[i,j] = clamp(abs(X),0,1);
	        }
	    }	
	
	maxheight = 0;
	highlandsA = 0;
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			if worldref[i,j] > 0 {world[i,j] = world[i,j]*(1+23*highlands[i,j])}
			maxheight = max(maxheight,world[i,j]);
			}
		}
	
	
	
	
	message = "Generating mountain peaks..."
	alarm[0]=2;
	}

	if step = 2 {
		
	//Mountain peaks reference
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			mountains_ref[i,j] = 0;
			if mountains[i,j] > 0 {
				mountains_ref[i,j] += terrain(100.00,Ox+0.65,Oy-0.24,3550,600,0.3,0,0.707,i,j);
				mountains_ref[i,j] += terrain(130.00,Ox-0.56,Oy-0.18,2731,0,0.3,0,1,i,j);
				mountains_ref[i,j] += terrain(169.00,Ox+0.71,Oy-0.13,2101,0,0.3,0,1,i,j);
			}
	    }
	}


	//Add mountains to base map
	maxheight = 0;
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			if mountains[i,j] > 0 {
				var k = sqrt(min(1,max(0,3*mountains[i,j]-1)))*clamp(worldref[i,j],0,3000);
				world[i,j] += lerp(0,mountains_ref[i,j],sqrt(mountains[i,j])) + k;
				maxheight = max(maxheight,world[i,j]);
			}
	    }
	}
	
	mountains_ref = 0;
		

	
	
   


	message = "Finalizing..."
	alarm[0]=2;
	}

	if step = 3 {
	
	//Sink ocean secondary
	var k = deep - shelf;
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			if world[i,j] < shelf {
	            var C = (world[i,j] - shelf)*2;
	            var D = power(abs(C/k),0.71);
	            world[i,j] = -abs(k*D);
	        }
		}
	}
		
	//loop edges
	for (var j = 0; j < gridheight; j ++) {
	    
		var A = mean(world[0,j],world[gridwidth-1,j]);
		world[0,j] = mean(A,world[0,j]);
		world[gridwidth-1,j] = mean(A,world[gridwidth-1,j]);
		
		}
	//var IN = 0;
    //var IS = 0;
	//for (var i = 0; i < gridwidth; i ++) {
		//IN += world[i,0];
		//IS += world[i,gridheight-1];
		//}
	//var N = IN/gridwidth;
	//var S = IS/gridwidth;
	//for (var i = 0; i < gridwidth; i ++) {
	    //for (var j = 0; j < equator-150; j++) {
	        //var tt = sqr(sqr(clamp((10-j)/10,0,1)));
	        //world[i,j] = lerp(world[i,j],N,tt);
	        //}
	    //for (var j = gridheight-1; j > equator+150; j--) {
	        //var t = 2*equator-j;
	        //var jj = sqr(sqr(clamp((10-t)/10,0,1)));
	        //world[i,j] = lerp(world[i,j],S,jj);
	        //}
	    //for (var j = 0; j < gridheight; j++) {
	        //maxheight = max(maxheight,world[t,j]);
	        //}
	    //}
    
	
	
	//Smoothed reference

	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			worldrefB[i,j] = world[i,j];
			if world[i,j] > 0 {worldrefB[i,j] += 500}
		}
	}
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -10; g < 11; g ++) {
				var ii = (i+g + gridwidth) mod gridwidth;
	            X += worldrefB[ii,j]*gauss21[g+10];
	            }
	        worldrefA[i,j] = X;
	        }
	    }
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
	        var X = 0;
	        for (var g = -10; g < 11; g ++) {
				var jj = clamp(j+g,0,gridheight-1);
	            X += worldrefA[i,jj]*gauss21[g+10];
	            }
	        worldref[i,j] = X;
	        }
	    }
	
	
	
	worldrefA = 0;
	worldrefB = 0;
	
    
	maxheight = 0;  
	
	//misc

	for (var i = 0; i < gridwidth; i ++) {
	    var il = (i-1+gridwidth) mod gridwidth; var ir = (i+1) mod gridwidth;
	    for (var j = 0; j < gridheight; j ++) {
	        maxheight = max(maxheight,world[i,j]);
	        var ju = max(0,j-1); var jd = min(gridheight-1,j+1);
	        var X = (world[il,ju] + 2*world[il,j] + world[il,jd] - world[ir,ju] - 2*world[ir,j] - world[ir,jd])/6;
	        var Y = (world[il,ju] + 2*world[i,ju] + world[ir,ju] - world[il,jd] - 2*world[i,jd] - world[ir,jd])/6;
	        var rX = (worldref[il,ju] + 2*worldref[il,j] + worldref[il,jd] - worldref[ir,ju] - 2*worldref[ir,j] - worldref[ir,jd])/6;
	        var rY = (worldref[il,ju] + 2*worldref[i,ju] + worldref[ir,ju] - worldref[il,jd] - 2*worldref[i,jd] - worldref[ir,jd])/6;
	        worldslope[i,j] = sqrt(max(0,sqr(X) + sqr(Y)));
	        worldangle[i,j] = point_direction(0,0,X,Y);
	        worldrefslope[i,j] = sqrt(sqr(rX) + sqr(rY));
	        worldrefangle[i,j] = point_direction(0,0,rX,rY);
	        worldrefx[i,j] = rX/max(worldrefslope[i,j],0.01);
	        worldrefy[i,j] = rY/max(worldrefslope[i,j],0.01);
	        var slope = worldslope[i,j];
	        var dir = degtorad(worldangle[i,j]+45);
	        relief[i,j] = clamp(sin(dir)*slope/1000,-1,1);
	        }
	    }
    
	}
    




}
