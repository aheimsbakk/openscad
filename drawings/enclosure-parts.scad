// Module for corners and middle


// Main dimensions
dimension = 25;
hole_diameter = 6;
peg_diameter = 4;
peg_length = dimension/8;

// Clearance in holes
clearance = 0.2;

// Resolution
$fs = .1;  // Minimum size (nossle)
$fa = 1;   // Minimum angle

module small_pegs(size=dimension, peg_diameter=peg_diameter, peg_length=peg_length, peg_diameter2=0) {
    one_forth = [
        [size/4, size/4, 0],
        [-size/4, size/4, 0],
        [size/4, -size/4, 0],
        [-size/4, -size/4, 0]
    ];

    for(i = one_forth)
        translate(i)
            translate([0,0,-size/2])
                if ( peg_diameter2>0 )
                    cylinder(peg_length, d1=peg_diameter, d2=peg_diameter2);
                else
                    cylinder(peg_length, d=peg_diameter);
}


module pice(size=dimension, hole_diameter=hole_diameter, hole_small=peg_diameter, hole_depth=peg_length, hollow=true) {
    sides = [
        [0,0,0],
        [90,0,0],
        [180,0,0],
        [270,0,0],
        [90,0,90],
        [90,0,270]
    ];
        
    difference() {
        intersection() {
            cube(size, center=true);
            sphere(d=size*1.415);    
        }
        
        if (hollow)
            cylinder(size, d=hole_diameter, center=true);

        for (i = sides)
            rotate(i)
                translate([0,0,-size/2])
                    cylinder(size/3, d=hole_diameter);
     
        for (i = sides)
          rotate(i)
            small_pegs(size, hole_small, hole_depth);   
    }
}

module stabilizator(size=dimension, hole_diameter=hole_diameter, peg_diameter=peg_diameter, peg_length=peg_length) {
    difference() {
        cylinder(size/2, d1=size, d2=size/1.5, center=true);
        cylinder(size/2, d=hole_diameter, center=true);
    }
    translate([0, 0, size/4-peg_length])
        small_pegs(size, peg_diameter);
}

module seal(size=dimension, peg_diameter=peg_diameter, peg_length=peg_length, peg_diameter2=peg_diameter) {
    cylinder(size/8, d=size, center=true);
    translate([0, 0, peg_length/2+size/2])
        small_pegs(size, peg_diameter, peg_length, peg_diameter2);
}

module ring(size=dimension, peg_diameter=peg_diameter, peg_length=peg_length, peg_diameter2=peg_diameter) {
    difference () {
        cylinder(size/16, d=size/1.66, center=true);
        cylinder(size/16, d=hole_diameter, center=true);   
    }
}


pice(dimension, hole_diameter + clearance, peg_diameter + clearance, peg_length + clearance);

translate([-dimension * 1.5, 0 , 0])
    pice(dimension, hole_diameter + clearance, peg_diameter + clearance, peg_length + clearance, false);


translate([dimension * 1.5, 0, 0])
    rotate([180])
        stabilizator(dimension, hole_diameter + clearance, peg_diameter, peg_length);

//translate([0, 0, dimension - 10])
translate([0, dimension * 1.5, 0])
    seal(dimension, peg_diameter, peg_length, peg_diameter);

translate([dimension * 1.5, dimension * 1.5, 0])
    seal(dimension, peg_diameter, peg_length, peg_diameter/1.5);

translate([-dimension * 1.5, dimension * 1.5, 0])
    ring(dimension, peg_diameter, peg_length, peg_diameter/1.5);

