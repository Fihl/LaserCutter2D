// Modified for 2D only, based on https://github.com/bmsleight/lasercut 
// Modified 2023 by OZ1AAB, Christen Fihl, https://github.com/Fihl

UP = 0;
DOWN = 180;
LEFT = 90;
RIGHT = 270;
MID = 360;

module lasercutoutSquare(thickness, x=0, y=0, 
        simple_tabs=[], simple_tab_holes=[], 
        captive_nuts=[], captive_nut_holes = [],
        finger_joints = [],
        bumpy_finger_joints = [],
        twist_holes=[], twist_connect=[],
        clips=[], clip_holes=[],
        circles_add = [],
        circles_remove = [],
        slits = [],
        cutouts = [],
        cutouts_vb = [],
        flat_adjust = [],
        milling_bit = 0.0,
)
{
    points = [[0,0], [x,0], [x,y], [0,y], [0,0]];
lasercutout(thickness=thickness,  
        points = points, 
        simple_tabs = simple_tabs, 
        simple_tab_holes = simple_tab_holes, 
        captive_nuts = captive_nuts, 
        captive_nut_holes = captive_nut_holes,
        finger_joints = finger_joints,
        bumpy_finger_joints = bumpy_finger_joints,
        twist_holes=twist_holes, twist_connect=twist_connect,
        clips=clips, clip_holes=clip_holes,
        circles_add = circles_add,
        circles_remove = circles_remove,
        slits = slits,
        cutouts = cutouts,
        cutouts_vb = cutouts_vb,
        flat_adjust = flat_adjust,
        milling_bit = milling_bit
    );
}

module lasercutout(thickness,  points= [], 
        simple_tabs=[], simple_tab_holes=[], 
        captive_nuts=[], captive_nut_holes = [],
        finger_joints = [],
        bumpy_finger_joints = [],
        twist_holes=[], twist_connect=[],
        clips=[], clip_holes=[],
        circles_add = [],
        circles_remove = [],
        slits = [],
        cutouts = [],
        cutouts_vb = [],
        flat_adjust = [],
        milling_bit = 0.0,
)
{
    function max_y(points) = max([for (a = [0:1:len(points)-1])  points[a][1]]);    
    function min_y(points) = min([for (a = [0:1:len(points)-1])  points[a][1]]);    
    function max_x(points) = max([for (a = [0:1:len(points)-1])  points[a][0]]);    
    function min_x(points) = min([for (a = [0:1:len(points)-1])  points[a][0]]);    
    
    max_y = max_y(points);
    min_y = min_y(points);
    max_x = max_x(points);
    min_x = min_x(points);
    
    difference() 
    { 
        union() 
        {
            //linear_extrude(height = thickness , center = false)  
                polygon(points=points);
            if(simple_tabs != undef) for (t = [0:1:len(simple_tabs)-1]) 
            {
                simpleTab(simple_tabs[t][0], simple_tabs[t][1], simple_tabs[t][2], thickness);
            }
            if(captive_nuts != undef) for (t = [0:1:len(captive_nuts)-1]) 
            {
                captiveNutTab(captive_nuts[t][0], captive_nuts[t][1], captive_nuts[t][2], thickness);
            }    
            if(circles_add != undef) for (t = [0:1:len(circles_add)-1]) 
            {
                circlesAdd(circles_add[t][0], circles_add[t][1], circles_add[t][2], thickness);
            }    
            if(finger_joints != undef) for (t = [0:1:len(finger_joints)-1]) 
            {
                fingerJoint(finger_joints[t][0], finger_joints[t][1], finger_joints[t][2], thickness, max_y, min_y, max_x, min_x);
            }    
            if(bumpy_finger_joints != undef) for (t = [0:1:len(bumpy_finger_joints)-1]) 
            {
                fingerJoint(bumpy_finger_joints[t][0], bumpy_finger_joints[t][1], bumpy_finger_joints[t][2], thickness, max_y, min_y, max_x, min_x, bumps=true);
            }  
        } // end union

        if(simple_tab_holes != undef) for (t = [0:1:len(simple_tab_holes)-1]) 
        {
            simpleTabHole(simple_tab_holes[t][0], simple_tab_holes[t][1], simple_tab_holes[t][2], thickness);
        }
        if(captive_nuts != undef) for (t = [0:1:len(captive_nuts)-1]) 
        {
            if (len(captive_nuts[t]) < 4) {
                captiveNutBoltHole(captive_nuts[t][0], captive_nuts[t][1], captive_nuts[t][2], thickness*3, thickness);
            } else {
                captiveNutBoltHole(captive_nuts[t][0], captive_nuts[t][1], captive_nuts[t][2], captive_nuts[t][3], thickness);
            }
        }
        if(captive_nut_holes != undef) for (t = [0:1:len(captive_nut_holes)-1]) 
        {
            captiveNutHole(captive_nut_holes[t][0], captive_nut_holes[t][1], captive_nut_holes[t][2], thickness);
        }    
        if(twist_holes != undef) for (t = [0:1:len(twist_holes)-1]) 
        {
            if(twist_holes[t][4] != undef) 
            {
                twistHole(twist_holes[t][0], twist_holes[t][1], twist_holes[t][2], twist_holes[t][3], thickness, spine=twist_holes[t][4]);
            }
            else
            {
                twistHole(twist_holes[t][0], twist_holes[t][1], twist_holes[t][2], twist_holes[t][3], thickness, spine=3*thickness);
            }
        }    
        if(twist_connect != undef) for (t = [0:1:len(twist_connect)-1]) 
        {
            if(twist_connect[t][3] != undef) 
            {
                twistConnect(twist_connect[t][0], twist_connect[t][1], twist_connect[t][2], thickness, max_y, min_y, max_x, min_x, spine=twist_connect[t][3]);
            }
            else
            {
                twistConnect(twist_connect[t][0], twist_connect[t][1], twist_connect[t][2], thickness, max_y, min_y, max_x, min_x, spine=thickness*3);
            }
        }    
        if(clips != undef) for (t = [0:1:len(clips)-1]) 
        {
            clipInner(clips[t][0], clips[t][1], clips[t][2], thickness);
        }    
        if(clip_holes != undef) for (t = [0:1:len(clip_holes)-1]) 
        {
            clipHole(clip_holes[t][0], clip_holes[t][1], clip_holes[t][2], thickness);
        }    
        if(circles_remove != undef) for (t = [0:1:len(circles_remove)-1]) 
        {
            circlesRemove(circles_remove[t][0], circles_remove[t][1], circles_remove[t][2], thickness);
        }    
        if(slits != undef) for (t = [0:1:len(slits)-1]) 
        {
               simpleSlit(slits[t][0], slits[t][1], slits[t][2], slits[t][3], thickness);
        }
        if(cutouts != undef) for (t = [0:1:len(cutouts)-1]) 
        {
               simpleCutouts(cutouts[t][0], cutouts[t][1], cutouts[t][2], cutouts[t][3], thickness);
        }
        if(cutouts_vb != undef) for (t = [0:1:len(cutouts_vb)-1]) 
        {
               simpleCutouts(cutouts_vb[t][0], cutouts_vb[t][1], cutouts_vb[t][2], cutouts_vb[t][3], thickness);
        }
        // Used for milling (not lasercutting) fingerJoint, 
        if (milling_bit > 0.0)
        {
            for (t = [0:1:len(finger_joints)-1]) 
            {
                    fingerJoint(finger_joints[t][0], finger_joints[t][1], finger_joints[t][2], thickness, max_y, min_y, max_x, min_x, not_mill=false, milling_bit=milling_bit);
            } 
        }
    }
    
    if (flat_adjust)
    {
        if ($children) translate([0 + flat_adjust[0], max_y(points) + thickness*3 + milling_bit*2 + flat_adjust[1], 0])
                children();
    }
    else
    {
        if ((thickness*2.5 + milling_bit*2) > 5)
        {
            if ($children) translate([0, max_y(points) + thickness*2.5 + milling_bit*2, 0])
                    children();        
        }
        else
        {
            if ($children) translate([0, max_y(points) + 5, 0])
                    children();                
        }
    }
}


module simpleTab(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) translate([-thickness/2,0]) square([thickness, thickness]); 
}

module simpleTabHole(angle, x, y, thickness)
{
     // Special case does not go past edge - so make only 1 thickness y
     if (angle == 360)
     {
         translate([x,y]) rotate([0,0]) translate([0,0,-thickness]) square([thickness, thickness]); 
     }
     else
     {
         translate([x,y]) rotate([0,0,angle-180]) translate([-thickness/2,-thickness]) square([thickness, thickness]); 
     }
}

module captiveNutBoltHole(angle, x, y, nut_flat_width, thickness)
{
    translate([x,y]) rotate([0,0,angle-180]) union() 
    {
        translate([-thickness/2,-thickness,-thickness]) square([thickness, thickness*4]); 
        echo(str("[LC] // screw thread major dia must be < ", thickness));
        echo(str("[LC] // screw thread length must be < ", thickness*5));
        translate([-nut_flat_width/2,thickness,-thickness]) square([nut_flat_width, thickness]); 
        echo(str("[LC] // nut thickness must be < ", thickness));
        echo(str("[LC] // nut flats must be < ", nut_flat_width));
    }
}

module fingerJoint(angle, start_up, fingers, thickness, max_y, min_y, max_x, min_x, bumps = false, not_mill=true, milling_bit=0)
{
    if ( angle == UP )
    {
        range_min = min_x; 
        range_max = max_x; 
        t_x = min_x;
        t_y = max_y;
        if(not_mill)
        {
            fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = bumps);
        }
        else
        {
            fingers_mill(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bit=milling_bit);
        }
    }
    if ( angle == DOWN )
    {
        range_min = min_x; 
        range_max = max_x; 
        t_x = max_x;
        t_y = min_y;
        if(not_mill)
        {
            fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = bumps);
        }
        else
        {
            fingers_mill(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bit=milling_bit);
        }
    }
    if ( angle == LEFT )
    {
        range_min = min_y; 
        range_max = max_y; 
        t_x = min_x;
        t_y = min_y;
        if(not_mill)
        {
            fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = bumps);
        }
        else
        {
            fingers_mill(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bit=milling_bit);
        }
    }
    if ( angle == RIGHT )
    {
        range_min = min_y; 
        range_max = max_y; 
        t_x = max_x;
        t_y = max_y;
        if(not_mill)
        {
            fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = bumps);
        }
        else
        {
            fingers_mill(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bit=milling_bit);
        }
    }

}


module fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = false)
{   
    // The tweaks to y translate([0,-thickness]) ... thickness*2 rather than *1
    // Are to avoid edge cases and make the dxf export better.
    // All fun
    kerf=0.0;// Hacky global for kerf
    translate([t_x, t_y]) rotate([0,0,angle]) translate([0,-thickness])
    {
        for ( p = [ 0 : 1 : fingers-1] )
		{
			
			i=range_min + ((range_max-range_min)/fingers)*p;
            if(start_up == 1) 
            {
				kerfSize = (p == 0) ? kerf/2 : kerf;
				kerfMove = (p == 0) ? 0 : kerf/2;
                translate([i-kerfMove,0]) 
                {
                    square([ (range_max-range_min)/(fingers*2) + kerfSize, thickness*2]);
                    if(bumps == true)
                    {
                        translate([(range_max-range_min)/(fingers*2)+ kerfSize, thickness*1.5, 0]) circle( r=thickness/10);
                    }
                }
            }
            else 
            {
				kerfSize = (p==fingers-1) ? kerf/2 : kerf;
				kerfMove = kerf/2;
                translate([i+(range_max-range_min)/(fingers*2)-kerfMove,thickness]) 
                {
                    square([ (range_max-range_min)/(fingers*2)+kerfSize, thickness]);
                    if(bumps == true)
                    {
                        if (i < (range_max - (range_max-range_min)/fingers ))
                        {
                            translate([(range_max-range_min)/(fingers*2)+ kerfSize, thickness*1.5, 0]) circle( r=thickness/10);
                        }
                    }
                }
            }
        }
    }

}

module fingers_mill(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bit=6.35/2)
{

    // The tweaks to y translate([0,-thickness]) ... thickness*2 rather than *1
    // Are to avoid edge cases and make the dxf export better.
    // All fun
    translate([t_x, t_y]) rotate([0,0,angle]) translate([0,-thickness])
    {
        for ( p = [ 0 : 1 : fingers-1] )
		{
            if(start_up == 1) 
            {
                translate([((range_max-range_min)/fingers)*p,0]) 
                {
                    translate([(range_max-range_min)/(fingers*2) + bit/2,thickness]) circle(d=bit, center=true );
                    translate([2*(range_max-range_min)/(fingers*2) - bit/2,thickness]) circle(d=bit, center=true );
                }
            }
            else 
            {
                translate([((range_max-range_min)/fingers)*p,0]) 
                {
                    translate([bit/2,thickness]) circle(d=bit, center=true );
                    translate([(range_max-range_min)/(fingers*2) - bit/2,thickness]) circle(d=bit, center=true );
                }
            }
        }
    }

}



module screwTab(angle, x, y, screw, thickness)
{
    translate([x,y]) rotate([0,0,angle]) translate([-screw/2,0]) square([screw*2, thickness+screw*2]); 
}

module screwTabHoleForScrew(angle, x, y, screw, thickness)
{
    // not to be confused with screwTabHole
    translate([x,y]) rotate([0,0,angle]) translate([screw/2,thickness+screw,-thickness]) circle(r=screw/2); 
}

module screwTabHole(angle, x, y, screw, thickness)
{
     // Special case does not go past edge - so make only 1 thickness y
     if (angle == 360)
     {
         translate([x,y]) rotate([0,0]) translate([0,0]) square([screw*2, thickness]); 
     }
     else
     {
         translate([x,y]) rotate([0,0,angle-180]) translate([-thickness/2,-thickness]) square([thickness, thickness*2]); 
     }
}


module captiveNutTab(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) union()
    {
        translate([-thickness/2+thickness*2,-thickness]) square([thickness*3, thickness*2]); 
        translate([-thickness/2-thickness*4,-thickness]) square([thickness*3, thickness*2]); 
    }
}

module captiveNutHole(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) union()
    {
        translate([-thickness/2,-thickness*2]) square([thickness, thickness]); 
        translate([-thickness/2+thickness*2,-thickness*2]) square([thickness*3, thickness3]); 
        translate([-thickness/2-thickness*4,-thickness*2]) square([thickness*3, thickness]); 
    }
}

module twistHole(angle, x, y, width, thickness, spine)
{
// http://msraynsford.blogspot.co.uk/2012/06/panel-joinery-10.html
    translate([x,y]) rotate([0,0,angle-90]) union()
    {
        square([width, thickness], center=true); 
        difference()
        {
            // Need some trig,  radius is hypo of triangle
            // Other sides are thinkness/2 and spine
            // 
            // 
           radius = sqrt(  ((thickness/2)*(thickness/2)) + ((spine/2)*(spine/2)) ); 
           translate([0,0]) circle(r=radius);
           translate([-thickness/2-spine/4,spine/4]) square([(spine/2), (spine/2)], center=true); 
           translate([+thickness/2+spine/4,-spine/4]) square([(spine/2), (spine/2)], center=true); 
        }
    }
}

module twistConnect(angle, x, y, thickness, max_y, min_y, max_x, min_x, spine)
{
    // Really should do trianometry for non-90 Angles, but hey ho
    if( (angle == LEFT) || (angle == RIGHT) )
    {
        translate([0,y]) rotate([0,0,angle+90]) union()
        {
            gap = max_x - min_x;
            translate([-gap/2-(spine/2),0]) square([gap, thickness]); 
            translate([+gap/2+(spine/2),0]) square([gap, thickness]); 
        }
    }
    if( (angle == UP) || (angle == DOWN) )
    {
        translate([x,0]) rotate([0,0,angle+90]) union()
        {
            gap = max_y - min_y;
            translate([-gap/2-(spine/2),0]) square([gap, thickness]); 
            translate([+gap/2+(spine/2),0]) square([gap, thickness]); 
        }
    }
}

module clipInner(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) union()
    {
        translate([-thickness/2-1,0])
        {
            translate([-(1+thickness)/2,-thickness*10]) square([1, thickness*11]);
            translate([(1+thickness)/2+1,-thickness*8])  
                //linear_extrude(height = thickness*3, center = true)  
                polygon(points=[[0,0],[0,9*thickness],[-(thickness-1), 9*thickness]]);
            translate([(1+thickness)/2+1-thickness+1,thickness-1]) square([thickness/2, thickness]);
            translate([-thickness*3/2,0]) square([thickness, thickness]);
        }
    }
}

module clipTab(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) union()
    {
        // make off-center
        translate([-thickness/2-1,0])
        {
            difference()
            {
                 translate([0,thickness/2,thickness/2]) square([thickness+1,thickness,thickness], center=true);
                 translate([(1+thickness)/2+1,-thickness*8])  
                 //linear_extrude(height = thickness*3, center = true)  
                polygon(points=[[0,0],[0,9*thickness],[-(thickness-1), 9*thickness]]);
            }
           translate([-thickness,thickness])  
                //linear_extrude(height = thickness)
                polygon(points=[[0,0],[thickness+1,0],[thickness,thickness-1],[1,thickness-1]]);
        }
        translate([0.5,0]) square([thickness,thickness]);
*       square([thickness*2+1,thickness], center=true);       
    }
}

module clipHole(angle, x, y, thickness)
{
    translate([x,y]) rotate([0,0,angle]) union()
    {
        translate([0,-thickness/2,thickness/2]) square([thickness*2+1,thickness,thickness*3], center=true);
    }
}

module circlesAdd(radius, x, y, thickness)
{
    translate([x,y]) circle( r=radius);
}

module circlesRemove(radius, x, y, thickness)
{
    translate([x,y]) circle(r=radius);
}


module simpleSlit(angle, x, y, length, thickness)
{
     translate([x,y]) rotate([0,0,angle-180]) translate([-thickness/2,-thickness]) square([thickness, length+thickness]);
}

module simpleCutouts(x, y, width, height, thickness)
{
    translate([x,y]) rotate([0,0]) translate([0,0]) square([width, height]);
}

