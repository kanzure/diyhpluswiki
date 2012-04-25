//vxb linear motion pillow block
//http://www.vxb.com/page/bearings/PROD/12mmLinearMotionSystems/Kit8512

//include <MCAD/materials.scad>
deg=pi/180;

module truck(){
    D=12; //one would think this would be on the datasheet
    h=15;
    E=21;
    W=42;
    L=36;
    F=28;
    h1=8;
    Angle=30;
    B=30.5;
    C=26;
    S=M5;

    //keyhole polygon
    x=F*cos(Angle);
    y=F*sin(Angle);

    color(Aluminum) linear_extrude(height=L) {     
        difference(){
            square([W,F]);
            translate([E,F-h])
                union() { 
                    circle(D/2);
                    rotate(-90) polygon(points=[[0,0], [x,-y], [x, y]]);
            }
        }
    }
}
truck();

