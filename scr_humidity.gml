function scr_humidity() {
	if step = 0 {
		
	
	
	for (var i = 0; i < gridwidth; i++) {
	    for (var j = 0; j < gridheight; j++) {
			
			var X = 0;
			var me = world[i,j]
			
			for (var s = -1; s < 2; s++) {
				
				var ii = (i+s + gridwidth) mod gridwidth;
				
				for (var t = -1; t < 2; t++) {
					
					var jj = clamp(j+t,0,gridheight-1);

					var you = max(0,world[ii,jj]);
					X += abs(me-you)/9;
					
				}
			}
			
			var B1 = clamp(1-abs(equator-j)/60,0,1);
			var B2 = clamp(1-abs(equator-130-j)/60,0,1);
			var B3 = clamp(1-abs(equator+130-j)/60,0,1);
			
			rainboost[i,j] = 1+max(B1,B2,B3);
			spread[i,j] = 1-clamp(X/250,0,1);
			
			//humidity_s[i,j] = 0;
			//humidity_w[i,j] = 0;
			//rainlevel_s[i,j] = 0;
			//rainlevel_w[i,j] = 0;
			for (var m = 0; m < 12; m ++) {
				var spd = (90-abs(angle_difference(worldangle[i,j],windamonth[m][i][j])))/90 * clamp(X/250,0,1);
				windspeedmonth[m][i][j] = (1 + pressuredmonth[m][i][j])*power(3,spd);
				humiditymonth[m][i][j] = 0;
				rainlevelmonth[m][i][j] = 0;
			}
		}
	}
	
	for (var j = 0; j < gridheight; j+=5) {
		for (var i = 0; i < gridwidth; i+=5) {
			for (var m = 0; m < 12; m ++) {
				var moisture = 0;
				if world[i,j] <= 0 {moisture = 20*(1-min(1,coast[i,j]/80))}
				var temp = climatemonth[m][i][j];
				var cur = currentmonth[m][i][j];
				var ii = i; var jj = j;
			
				for (var k = 0; k < 40; k++) {
				
				
					var A = min(sqr((ITCZmonth[m][ii]-jj)/120)+1,4);
					var d = 30*noise_y[mean(i,j),k];
					var I = (ii + 2*A*windspeedmonth[m][ii][jj]*lengthdir_x(1,d+windamonth[m][ii][jj]) + gridwidth) mod gridwidth;
					var J = clamp(jj + 2*windspeedmonth[m][ii][jj]*lengthdir_y(1,d+windamonth[m][ii][jj]),0,gridheight-1);
				
					var tt = climatemonth[m][I][J];
					temp = tt*0.2+(temp+cur*5)*0.8;
					if world[I,J] <= 0 {
					
						var water = ( clamp(climatemonth[m][I][J],-8,0) + 4 ) * 0.25;
						moisture = min(20,moisture+water);
						cur = lerp(cur,currentmonth[m][I][J],0.4);
					
					}
					else {
						var r = exp((tt-temp)*0.2);
						moisture = max(0,moisture-r);
					}
				
					if moisture > 0 {
						
						var hotwind = clamp(temp-min(24,climatemonth[m][I][J]),-1,2)*5
						humiditymonth[m][I][J] += (5+rainboost[I,J]*2+hotwind)*sqrt(moisture/20);
						
						for (var s = -1; s < 2; s++) {
							var II = (I+s + gridwidth) mod gridwidth;
							for (var t = -1; t < 2; t++) {
								var JJ = clamp(J+t,0,gridheight-1);
								humiditymonth[m][II][JJ] += (5+rainboost[I,J]*2+hotwind)*sqrt(moisture/20);
							}
						}
						
					}
				
					ii = I;
					jj = J;
				
				}
			
			}
			
		}
	}
	
	for (var j = 0; j < gridheight; j++) {
		for (var i = 0; i < gridwidth; i++) {
			treecover[i,j] = 0;
			for (var m = 0; m < 12; m ++) {
				treecover[i,j] = min( 1 , max(0,humiditymonth[m][i][j]/75) );
			}
		}
	}
	
	for (var j = 0; j < gridheight; j+=5) {
		for (var i = 0; i < gridwidth; i+=5) {
			if treecover[i,j] > 0 && world[i,j] > 0 {
				for (var m = 0; m < 12; m ++) {
					var mm = (m + 6) mod 12;
					var moisture = treecover[i,j]*exp(0.05*max(0,climatemonth[mm][i][j])-0.05*max(0,climatemonth[m][i][j]));
					var ii = i; var jj = j;
				
				
					for (var k = 0; k < 8; k++) {
				
						var A = min(sqr((ITCZ_s[ii]-jj)/120)+1,4);
						var d = 50*noise_y[mean(i,j),k];
						var I = (ii + 4*A*windspeedmonth[m][ii][jj]*lengthdir_x(1,d+windamonth[m][ii][jj]) + gridwidth) mod gridwidth;
						var J = clamp(jj + 4*windspeedmonth[m][ii][jj]*lengthdir_y(1,d+windamonth[m][ii][jj]),0,gridheight-1);
				
						if moisture > 0 {
						
							humiditymonth[m][I][J] += moisture*0.15;
						
							for (var s = -3; s < 4; s++) {
								var II = (I+s + gridwidth) mod gridwidth;
								for (var t = -3; t < 4; t++) {
									var JJ = clamp(J+t,0,gridheight-1);
									var X = max(0,4-0.7*(abs(s)+abs(t)))/4;
									if !(s = 0 && t = 0) {humiditymonth[m][II][JJ] += moisture*0.15*X*spread[II,JJ]}
								}
							}
						
						}
				
						moisture = max(0,moisture/2);
						ii = I;
						jj = J;
				
					}
				}
			}
		}
	}
	
	

    
   

	message = "Dispersing rain..."
	alarm[3]=2;		
	}

	if step = 1 {
		
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			for (var m = 0; m < 12; m ++) {
			humidityAmonth[m][i][j] = power(abs(humiditymonth[m][i][j])*0.01,0.7)*100;
			}
		}
	}
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			for (var m = 0; m < 12; m ++) {
			var m_next = (m+1) mod 12; var m_prev = (m+11) mod 12;
			humiditymonth[m][i][j] = mean(  humidityAmonth[m][i][j]  ,     mean( mean(humidityAmonth[m][i][j],humidityAmonth[m_next][i][j]) , mean(humidityAmonth[m][i][j],humidityAmonth[m_prev][i][j]) )    );
			}
		}
	}
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			for (var m = 0; m < 12; m ++) {
				var X = 0;
				for (var g = -6; g < 7; g++) {
					var ii = (i+g + gridwidth) mod gridwidth;
					X += humiditymonth[m][ii][j]*gauss13[g+6];
				}
				humidityAmonth[m][i][j] = X;
			}
		}
	}
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			for (var m = 0; m < 12; m ++) {
				var X = 0;
				for (var g = -6; g < 7; g++) {
					var jj = clamp(j+g,0,gridheight-1);
					X += humidityAmonth[m][i][jj]*gauss13[g+6];
				}
				humiditymonth[m][i][j] = lerp(humiditymonth[m][i][j],X,spread[i,j]);
				
			}
		}
	}
	
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			//rainlevel_s[i,j] = humidity_s[i,j]/120;
			//rainlevel_w[i,j] = humidity_w[i,j]/120;
	        //humidity_s[i,j] = clamp(humidity_s[i,j],0,100);
	       // humidity_w[i,j] = clamp(humidity_w[i,j],0,100);
			
			for (var m = 0; m < 12; m ++) {
				
				rainlevelmonth[m][i][j] = humiditymonth[m][i][j]/120;
				var H = clamp(humiditymonth[m][i][j],0,100);
				humiditymonth[m][i][j] = H;
				var col = make_color_rgb(190,232,254);
				if world[i,j] > 0 {
					if H < aridH {col = make_color_rgb(216,192,182)}
					else if H < semiaridH {col = make_color_rgb(182,134,156)}
					else if H < semihumidH {col = make_color_rgb(163,112,153)}
					else if H < humidH {col = make_color_rgb(73,60,106)}
					else {col = make_color_rgb(46,45,89)}
				}
				humiditybandmonth[m][i][j] = col;
	        }
	    }
	}

    
	//for (var t = 0; t < gridheight; t ++) {
	    //for (var s = 0; s < gridwidth; s ++) {
	        //if humidity_s[s,t] < aridH {humidityband_s[s,t] = 0}
	        //else if humidity_s[s,t] < semiaridH {humidityband_s[s,t] = 1}
	        //else if humidity_s[s,t] < semihumidH {humidityband_s[s,t] = 2}
	        //else if humidity_s[s,t] < humidH {humidityband_s[s,t] = 3}
	        //else {humidityband_s[s,t] = 4}
	        //}
	    //}
    
	//for (var t = 0; t < gridheight; t ++) {
	    //for (var s = 0; s < gridwidth; s ++) {
	        //if humidity_w[s,t] < aridH {humidityband_w[s,t] = 0}
	        //else if humidity_w[s,t] < semiaridH {humidityband_w[s,t] = 1}
	        //else if humidity_w[s,t] < semihumidH {humidityband_w[s,t] = 2}
	        //else if humidity_w[s,t] < humidH {humidityband_w[s,t] = 3}
	        //else {humidityband_w[s,t] = 4}
	        //}
	    //}
		
	message = "Calculating real values..."
	alarm[3]=2;
	}

	if step = 2 {   
		
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			for (var m = 0; m < 12; m ++) {
				//Rain mm/month
				var temp = min(climatemonth[m][i][j],50);
				var rain = clamp(rainlevelmonth[m][i][j]/2,0,2);
				var Rmax1 = 180*exp(0.033*temp);
				var Rmax2 = -max(power((temp-25)*0.5,3),0);
				rainmonth[m][i][j] = max(0,Rmax1 + Rmax2)*rain;
			
				//PET
				PETmonth[m][i][j] = 0;
				temp = climatemonth[m][i][j];
				if temp > 0 {
					var sky_clearness = 1 - 0.5*sqrt(humiditymonth[m][i][j]/100)/(1+max(0,pressuremonth[m][i][j]));
					PETmonth[m][i][j] = clamp(temp/30,0,1)*200*sky_clearness;
				}
			
				//aridity
				ariditymonth[m][i][j] = rainmonth[m][i][j]/(PETmonth[m][i][j]+1);
			}
		}
	}
	
	//Continentality, rain and temp graph
    for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			
			var Tmax = 0; var Tmin = 0; var Rmax = 300;
			for (var m = 0; m < 12; m ++) {
				Tmax = max(Tmax,climatemonth[m][i][j]);
				Tmin = min(Tmin,climatemonth[m][i][j]);
				Rmax = max(Rmax,rainmonth[m][i][j]);
			}
			
			//var d = abs(Tmax-Tmin);
			//var lat = clamp(abs(equator-j)*0.5,10,90);
			//var M = 0.00034*lat*lat - 0.01551*lat + 0.37451;
			//var C = 0.00002*lat*lat - 0.00339*lat - 0.46642;
			//cont[i,j] = M*d + C;
			
			tempgraphmax[i,j] = ceil(Tmax/10)*10;
			tempgraphmin[i,j] = floor(Tmin/20)*20;
			tempgraphmean[i,j] = mean(tempgraphmax[i,j],tempgraphmin[i,j]);
			raingraphmax[i,j] = ceil(Rmax/100)*100;
			raingraphmean[i,j] = raingraphmax[i,j]/2;
			
			for (var m = 0; m < 12; m ++) {
				tempgraph[m][i][j] = (climatemonth[m][i][j] - tempgraphmin[i,j])/(tempgraphmax[i,j] - tempgraphmin[i,j]);
				raingraph[m][i][j] = rainmonth[m][i][j]/raingraphmax[i,j];
			}
			
		}
	}

	
	}
}

function scr_humiditys() {
	if step = 0 {
		
	
	
	for (var i = 0; i < gridwidth; i++) {
	    for (var j = 0; j < gridheight; j++) {
			
			var X = 0;
			var me = world[i,j]
			
			for (var s = -1; s < 2; s++) {
				
				var ii = (i+s + gridwidth) mod gridwidth;
				
				for (var t = -1; t < 2; t++) {
					
					var jj = clamp(j+t,0,gridheight-1);

					var you = max(0,world[ii,jj]);
					X += abs(me-you)/9;
					
				}
			}
			
			spread[i,j] = 1-clamp(X/250,0,1);
			var speed_s = (90-abs(angle_difference(worldangle[i,j],winda_s[i,j])))/90 * clamp(X/250,0,1);
			var speed_w = (90-abs(angle_difference(worldangle[i,j],winda_w[i,j])))/90 * clamp(X/250,0,1);
			humidity_s[i,j] = 0;
			humidity_w[i,j] = 0;
			rainlevel_s[i,j] = 0;
			rainlevel_w[i,j] = 0;
			
			var B1 = clamp(1-abs(equator-j)/60,0,1);
			var B2 = clamp(1-abs(equator-130-j)/60,0,1);
			var B3 = clamp(1-abs(equator+130-j)/60,0,1);
			rainboost[i,j] = 1+max(B1,B2,B3);
			
			windspeed_s[i,j] = (1 + pressured_s[i,j])*power(3,speed_s);
			windspeed_w[i,j] = (1 + pressured_w[i,j])*power(3,speed_w);
		}
	}
	
	for (var j = 0; j < gridheight; j+=4) {
		for (var i = 0; i < gridwidth; i+=4) {
			
			var m_s = 0; var m_w = 0;
			if world[i,j] <= 0 {m_s = 20*(1-min(1,coast[i,j]/80)); m_w = m_s;}
			var t_s = climate_s[i,j]; var t_w = climate_w[i,j];
			var c_s = current_s[i,j]; var c_w = current_w[i,j];
			var i_s = i; var j_s = j; var i_w = i; var j_w = j;
			
			for (var k = 0; k < 40; k++) {
				
				
				var A = min(sqr((ITCZ_s[i_s]-j_s)/120)+1,4);
				var d = 30*noise_y[mean(i,j),k];
	            var I = (i_s + 2*A*windspeed_s[i_s,j_s]*lengthdir_x(1,d+winda_s[i_s,j_s]) + gridwidth) mod gridwidth;
	            var J = clamp(j_s + 2*windspeed_s[i_s,j_s]*lengthdir_y(1,d+winda_s[i_s,j_s]),0,gridheight-1);
				
				var tt = climate_s[I,J];
				t_s = t_s*0.7+(tt+c_s*5)*0.3;
				if world[I,J] <= 0 {
					
					var water = ( clamp(climate_s[I,J],-8,0) + 4 ) * 0.25;
					m_s = min(20,m_s+water);
					c_s = lerp(c_s,current_s[I,J],0.4);
					
				}
				else {
					var r = exp((tt-t_s)*0.2);
					m_s = max(0,m_s-r);
				}
				
				if m_s > 0 {
						
					var hotwind = clamp(t_s-min(24,climate_s[I,J]),0,2)*5
					humidity_s[I,J] += (5+rainboost[I,J]*2+hotwind)*sqrt(m_s/20);
						
					for (var s = -1; s < 2; s++) {
						var ii = (I+s + gridwidth) mod gridwidth;
						for (var t = -1; t < 2; t++) {
							var jj = clamp(J+t,0,gridheight-1);
							humidity_s[ii,jj] += (5+rainboost[I,J]*2+hotwind)*m_s/20;
						}
					}
						
				}
				
				i_s = I;
				j_s = J;
				
			}
			
			for (var k = 0; k < 40; k++) {
				
				var A = min(sqr((ITCZ_w[i_w]-j_w)/120)+1,4);
				var d = 30*noise_y[mean(i,j),k];
	            var I = (i_w + 2*A*windspeed_w[i_w,j_w]*lengthdir_x(1,d+winda_w[i_w,j_w]) + gridwidth) mod gridwidth ;
	            var J = clamp(j_w + 2*windspeed_w[i_w,j_w]*lengthdir_y(1,d+winda_w[i_w,j_w]),0,gridheight-1);
				
				var tt = climate_w[I,J];
				t_w = t_w*0.7+(tt+c_w*5)*0.3;
				if world[I,J] <= 0 {
					
					var water = ( clamp(climate_w[I,J],-8,0) + 4 ) * 0.25;
					m_w = min(20,m_w+water);
					c_w = lerp(c_w,current_w[I,J],0.4);
					
				}
				else {
					var r = exp((tt-t_w)*0.2);
					m_w = max(0,m_s-r);
				}
				
				if m_w > 0 {
						
					var hotwind = clamp(t_w-min(24,climate_w[I,J]),-1,2)*5
					humidity_w[I,J] += (5+rainboost[I,J]*2+hotwind)*sqrt(m_w/20);
						
					for (var s = -1; s < 2; s++) {
						var ii = (I+s + gridwidth) mod gridwidth;
						for (var t = -1; t < 2; t++) {
							var jj = clamp(J+t,0,gridheight-1);
							humidity_w[ii,jj] += (5+rainboost[I,J]*2+hotwind)*m_w/20;
						}
					}
						
				}
				
				i_w = I;
				j_w = J;
			}
			
		}
	}
	
	for (var j = 0; j < gridheight; j++) {
		for (var i = 0; i < gridwidth; i++) {
			treecover[i,j] = min( 1 , max(0,humidity_s[i,j],humidity_w[i,j])/100 );
		}
	}
	
	for (var j = 0; j < gridheight; j+=5) {
		for (var i = 0; i < gridwidth; i+=5) {
			if treecover[i,j] > 0 && world[i,j] > 0 {
				
				var m_s = treecover[i,j]*exp(0.05*max(0,climate_w[i,j])-0.05*max(0,climate_s[i,j])); var m_w = treecover[i,j]*exp(0.05*max(0,climate_s[i,j])-0.05*max(0,climate_w[i,j]));
				var t_s = climate_s[i,j]; var t_w = climate_w[i,j];
				var i_s = i; var j_s = j; var i_w = i; var j_w = j;
				
				
				for (var k = 0; k < 8; k++) {
				
				var A = min(sqr((ITCZ_s[i_s]-j_s)/120)+1,4);
				var d = 50*noise_y[mean(i,j),k];
	            var I = (i_s + 4*A*windspeed_s[i_s,j_s]*lengthdir_x(1,d+winda_s[i_s,j_s]) + gridwidth) mod gridwidth;
	            var J = clamp(j_s + 4*windspeed_s[i_s,j_s]*lengthdir_y(1,d+winda_s[i_s,j_s]),0,gridheight-1);
				
				if m_s > 0 {
						
					humidity_s[I,J] += m_s*0.125;
						
					for (var s = -3; s < 4; s++) {
						var ii = (I+s + gridwidth) mod gridwidth;
						for (var t = -3; t < 4; t++) {
							var jj = clamp(J+t,0,gridheight-1);
							var X = max(0,4-0.7*(abs(s)+abs(t)))/4;
							if !(s = 0 && t = 0) {humidity_s[ii,jj] += m_s*0.125*X*spread[ii,jj]}
						}
					}
						
				}
				
				m_s = max(0,m_s/2);
				i_s = I;
				j_s = J;
				
			}
			
			
			for (var k = 0; k < 8; k++) {
				
				var A = min(sqr((ITCZ_w[i_w]-j_w)/120)+1,4);
				var d = 50*noise_y[mean(i,j),k];
	            var I = (i_w + 4*A*windspeed_w[i_w,j_w]*lengthdir_x(1,d+winda_w[i_w,j_w]) + gridwidth) mod gridwidth;
	            var J = clamp(j_w + 4*windspeed_w[i_w,j_w]*lengthdir_y(1,d+winda_w[i_w,j_w]),0,gridheight-1);
				
				if m_w > 0 {
						
					humidity_w[I,J] += m_w*0.08;
						
					for (var s = -3; s < 4; s++) {
						var ii = (I+s + gridwidth) mod gridwidth;
						for (var t = -3; t < 4; t++) {
							var jj = clamp(J+t,0,gridheight-1);
							var X = max(0,4-0.7*(abs(s)+abs(t)))/4;
							if !(s = 0 && t = 0) {humidity_w[ii,jj] += m_w*0.08*X*spread[ii,jj]}
						}
					}
						
				}
				
				m_w = max(0,m_w/2);
				i_s = I;
				j_s = J;
				
			}
			
			
			}
		}
	}
	
	

    
   

	message = "Dispersing rain..."
	alarm[3]=2;		
	}

	if step = 1 {
		
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			humidity_s[i,j] = sqrt(humidity_s[i,j]*0.01)*100;
			humidity_w[i,j] = sqrt(humidity_w[i,j]*0.01)*100;
		}
	}
	
	
	for (var count = 0; count < 2; count++) {
		for (var i = 0; i < gridwidth; i++) {
			for (var j = 0; j < gridheight; j++) {
				var X_s = 0;
				var X_w = 0;
				for (var g = -3; g < 4; g++) {
					var ii_s = (i+g-windx_s[i,j] + gridwidth) mod gridwidth;
					var ii_w = (i+g-windx_w[i,j] + gridwidth) mod gridwidth;
					X_s += humidity_s[ii_s,j]*gauss1D[g+3];
					X_w += humidity_w[ii_w,j]*gauss1D[g+3];
				}
				humidityA_s[i,j] = X_s;
				humidityA_w[i,j] = X_w;
			}
		}
		for (var i = 0; i < gridwidth; i++) {
			for (var j = 0; j < gridheight; j++) {
				var X_s = 0;
				var X_w = 0;
				for (var g = -3; g < 4; g++) {
					var jj_s = clamp(j+g-windy_s[i,j],0,gridheight-1);
					var jj_w = clamp(j+g-windy_w[i,j],0,gridheight-1);
					X_s += humidityA_s[i,jj_s]*gauss1D[g+3];
					X_w += humidityA_w[i,jj_w]*gauss1D[g+3];
				}
				humidity_s[i,j] = lerp(humidity_s[i,j],X_s,spread[i,j]);
				humidity_w[i,j] = lerp(humidity_w[i,j],X_w,spread[i,j]);
			}
		}
	}
	
	
	for (var i = 0; i < gridwidth; i++) {
		for (var j = 0; j < gridheight; j++) {
			rainlevel_s[i,j] = humidity_s[i,j]/120;
			rainlevel_w[i,j] = humidity_w[i,j]/120;
	        humidity_s[i,j] = clamp(humidity_s[i,j],0,100);
	        humidity_w[i,j] = clamp(humidity_w[i,j],0,100);
	        }
	    }
    

    
	for (var t = 0; t < gridheight; t ++) {
	    for (var s = 0; s < gridwidth; s ++) {
	        if humidity_s[s,t] < aridH {humidityband_s[s,t] = 0}
	        else if humidity_s[s,t] < semiaridH {humidityband_s[s,t] = 1}
	        else if humidity_s[s,t] < semihumidH {humidityband_s[s,t] = 2}
	        else if humidity_s[s,t] < humidH {humidityband_s[s,t] = 3}
	        else {humidityband_s[s,t] = 4}
	        }
	    }
    
	for (var t = 0; t < gridheight; t ++) {
	    for (var s = 0; s < gridwidth; s ++) {
	        if humidity_w[s,t] < aridH {humidityband_w[s,t] = 0}
	        else if humidity_w[s,t] < semiaridH {humidityband_w[s,t] = 1}
	        else if humidity_w[s,t] < semihumidH {humidityband_w[s,t] = 2}
	        else if humidity_w[s,t] < humidH {humidityband_w[s,t] = 3}
	        else {humidityband_w[s,t] = 4}
	        }
	    }
		
	message = "Calculating real values..."
	alarm[3]=2;
	}

	if step = 2 {   
		
	
	for (var i = 0; i < gridwidth; i ++) {
	    for (var j = 0; j < gridheight; j ++) {
			
			//Rain mm/month
			var t_s = clamp(climate_s[i,j],0,50);
			var t_w = clamp(climate_w[i,j],0,50);
			var h_s = rainlevel_s[i,j]/2;
			var h_w = rainlevel_w[i,j]/2;
			var Rmax1_s = power(1.07,t_s)*10;
			var Rmax1_w = power(1.07,t_w)*10;
			var Rmax2_s = -max(power((t_s-15)*0.2,3),0);
			var Rmax2_w = -max(power((t_w-15)*0.2,3),0);
			rain_s[i,j] = 10*max(0,Rmax1_s + Rmax2_s)*h_s;
			rain_w[i,j] = 10*max(0,Rmax1_w + Rmax2_w)*h_w;
			
			//PET
			PET_s[i,j] = 0;
			var T_s = climate_s[i,j];
			if T_s > 0 {
				var sky_clearness = 1 - 0.5*sqrt(humidity_s[i,j]/100)/(1+max(0,pressure_s[i,j]));
				PET_s[i,j] = clamp(T_s/30,0,1)*200*sky_clearness;
			}
			PET_w[i,j] = 0;
			var T_w = climate_w[i,j];
			if T_w > 0 {
				var sky_clearness = 1 - 0.5*sqrt(humidity_w[i,j]/100)/(1+max(0,pressure_w[i,j]));
				PET_w[i,j] = clamp(T_w/30,0,1)*200*sky_clearness;
			}
			
			//aridity
	        aridity_s[i,j] = rain_s[i,j]/(PET_s[i,j]+1);
	        aridity_w[i,j] = rain_w[i,j]/(PET_w[i,j]+1);
			
		}
	}
    
	
	//for (var t = 0; t < gridheight; t ++) {
	    //for (var s = 0; s < gridwidth; s ++) {
			//var ks = sqr(clamp(climate_s[s,t],0,30)/30);
			//var kw = sqr(clamp(climate_w[s,t],0,30)/30);
			//var as = 1-humidity_s[s,t]*0.01;
			//var aw = 1-humidity_w[s,t]*0.01;
			//var has = as*1.11111;
			//var haw = aw*1.11111;
			//var cas = power(as,10);
			//var caw = power(aw,10);
	        //aridity_s[s,t] = min(1,lerp(cas,has,ks));
	        //aridity_w[s,t] = min(1,lerp(caw,haw,kw));
	        //}
	    //}

	for (var t = 0; t < gridheight; t ++) {
	    for (var s = 0; s < gridwidth; s ++) {
			var t_s = climate_s[s,t];
			var t_w = climate_w[s,t];
			var d = abs(t_s-t_w);
			var lat = clamp(abs(equator-t)*0.5,10,90);
			var m = 0.00034*lat*lat - 0.01551*lat + 0.37451;
			var c = 0.00002*lat*lat - 0.00339*lat - 0.46642;
			cont[s,t] = m*d + c;
	        }
	    }
	}
}

