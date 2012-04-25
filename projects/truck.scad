//vxb linear motion pillow block
//block http://www.vxb.com/page/bearings/PROD/12mmLinearMotionSystems/Kit8512
//bearing insert http://www.bergab.ru/price/img/samick/LME12OP_samick.jpg

include <MCAD/materials.scad>

module LME12UU_OP(){
    ID=12;
    OD=22;
    L=32;
    Angle=78;
    //keyhole polygon, Angle is the included angle
    x=OD*cos(Angle/2);
    y=OD*sin(Angle/2);
    color(Stainless) linear_extrude(height=L){
        difference(){
            circle(OD/2);    
            union() {
                circle(ID/2);
                rotate(-90) polygon(points=[[0,0], [x,-y], [x, y]]);
            }
        }
    }
}

module truck(){
    D=22; //one would think this would be on the datasheet
    h=15;
    E=21;
    W=42;
    L=36;
    F=28;
    h1=8;
    Angle=80;
    B=30.5;
    C=26;
    S=M5;
    hole_depth=5;

    //keyhole polygon, Angle is the included angle
    x=F*cos(Angle/2);
    y=F*sin(Angle/2);

    union(){
        difference(){
            translate([-E, -(F-h), -L/2]) 
                color(Aluminum) linear_extrude(height=L) difference(){
                    square([W,F]);
                    translate([E,F-h])
                        union() { 
                            circle(D/2);
                            rotate(-90) polygon(points=[[0,0], [x,-y], [x, y]]);
                        }
                }
            //mounting screw holes
            //maybe i'll get rid of this, it messes up the CSG
            rotate(a=[-90]) translate([B/2,C/2,h-hole_depth]) cylinder(h=hole_depth+1, r=5/2);
            rotate(a=[-90]) translate([-B/2,C/2,h-hole_depth]) cylinder(h=hole_depth+1, r=5/2);
            rotate(a=[-90]) translate([B/2,-C/2,h-hole_depth]) cylinder(h=hole_depth+1, r=5/2);
            rotate(a=[-90]) translate([-B/2,-C/2,h-hole_depth]) cylinder(h=hole_depth+1, r=5/2);
        }
        
        //bearing insert
        translate([0,0,-L/2+2]) LME12UU_OP();
    }

}
truck();

