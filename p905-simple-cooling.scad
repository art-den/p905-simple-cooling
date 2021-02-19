////////////////////////////////////////////////////////////////////

/* Параметры модели */

l1 = 1.5; // толщина стенки
l2 = 23; // расстояние от вентилятора до сопла хотэнда
l3 = 37; // расстояние между соплами
l4 = 10; // ширина воздуховода
l5 = 3; // фаска
l6 = 5; // длина сопла
l11 = 14; // ширина сопла
l7 = 30; // высота

d1 = 28; // диаметр отверстия под вентилятор
d2 = 2.9; // диаметр отверстия для винтов крепления вентилятора
l8 = 24; // расстояние между отверстиями для крепления вентилятора

l9 = 8.5; // высота сопла в толстой части
l10 = 5; // высота сопла в выходной части

l12 = 6; // расстояние по горизонтали от центра сопла хотэнда до края радиатора
l15 = 11; // расстояние от верхней части обдува до дна радиатора (для ограничения длины ребра крепления)

l16 = 13; // ширина центрального ребра
l17 = 7; // расстояние по вертикали от верха до крепления к радиатору
l18 = 36; // расстояние между дырками для крепления к радиатору
d3 = 3.2; // диаметр дырки для крепления к радиатору
l19 = 2; // толщина алюминиевой пластины крепления на радиатор.

////////////////////////////////////////////////////////////////////

$fn = 32;

t1 = l2 + l11/2;
t2 = l2 - l11/2;
t3 = l3/2 + l6 + l4;

dl = 0.01;

// Проекция основной части копуса на XY
module main_shape()
{
    l5_ = l5*2.3;
    
    polygon([
        [-(t3-l5_), 0],
        [-t3, l5_],
        [-t3, t1-l5],
        [-(t3-l5), t1],
        [-(t3-l4), t1],
        [-(t3-l4), l4+l5],
        [-(t3-l4-l5), l4],
    
        [-l8/2, l4],
        [0, l4 * 0.60],
        [l8/2, l4],
    
        [t3-l4-l5, l4],
        [t3-l4, l4+l5],
        [t3-l4, t1],
        [t3-l5, t1],
        [t3, t1-l5],
        [t3, l5_],
        [t3-l5_, 0],
    ]);
}

// Проекция основной части корпуса на YZ
module profile_shape()
{
    polygon([
        [0, 0],
        [0, l7],
        [l1, l7],
        [t1, l9],
        [t1, 0]
    ]);
}

module main_body()
{
    // стены
    intersection()
    {
        linear_extrude(l7, convexity = 4) difference()
        {
            main_shape();
            
            offset(-l1)
                main_shape();
        }

        translate([-t3, 0, 0])
        {
            rotate([90, 0, 90]) 
                linear_extrude(2*t3, convexity = 4) 
                    profile_shape();
        }
    }

    // крыша/потолок
    intersection()
    {
        translate([-t3, 0, 0])
        {
            rotate([90, 0, 90]) 
                linear_extrude(2*t3, convexity = 4) difference()
                {
                    profile_shape();
                    offset(-l1)
                        profile_shape();
                }
        }
        
        linear_extrude(l7, convexity = 4) difference()
            main_shape();
    }
}

module body_volume()
{
    intersection()
    {
        linear_extrude(l7, convexity = 4)
            main_shape();

        translate([-t3, 0, 0])
        {
            rotate([90, 0, 90]) 
                linear_extrude(2*t3, convexity = 4) 
                    profile_shape();
        }
    }

}

module soplo_shape()
{
    diff_x = (l9 - l10) * 0.5;
    
    polygon([
        [0, 0],
        [0, l1],
        [l6-diff_x, l1],
        [l6-diff_x, 0]
    ]);
    
    polygon([
        [0, l9],
        [l6, l10],
        [l6, l10-l1],
        [0, l9-l1]
    ]);
    
}

module soplo()
{
    linear_extrude(l11, convexity = 4)
        soplo_shape();
   
    linear_extrude(l1, convexity = 4)
        hull() 
            soplo_shape();
    
    translate([0, 0, l11-l1])
        linear_extrude(l1, convexity = 4)
            hull() 
                soplo_shape();
}

module rebro(t11, l, dh)
{
    linear_extrude(l, convexity = 4) difference() 
    {
        polygon([
            [0, l7],
            [t11, l7],
            [t11, l7 - (l15+dh)],
            [0, l7 - (l15+dh)-t11*0.7],
        ]);
    }
}


difference()
{
    union()
    {
        // основной корпус
        main_body();
    
        // втулки под крепление вентиятора
        for (i = [-1:2:1]) for (j = [-1:2:1])
            translate([i*l8/2, 0, l7/2+j*l8/2])
                rotate([-90, 0, 0]) cylinder(d = l7-l8, h = l4-l1/2);
        
        difference()
        {
            union()
            {
                // Рёбра, которыми воздуходувка упирается в радиатор
                translate([-l16/2, 0, 0])
                    rotate([90, 0, 90])
                        rebro(l2 - l12 - l19, l16, 0);
                
                translate([-l18/2-d3/2, 0, 0])
                    rotate([90, 0, 90])
                        rebro(l2 - l12 - l19, d3, l19);
                
                translate([l18/2-d3/2, 0, 0])
                    rotate([90, 0, 90])
                        rebro(l2 - l12 - l19, d3, l19);
            }
            
            body_volume();
        }
        
        
        // втулки для крепления к радиатору
        for (i = [-1:2:1]) 
            translate([i*l18/2, 0, l7 - l17])
                rotate([-90, 0, 0]) cylinder(d = 7, h = l2 - l12 - l19);
    }
  
    // Большая дырка под вентилятор
    translate([0, -dl, l7/2])
        rotate([-90, 0, 0])
            cylinder(d = d1, h = l1+2*dl);
    
    // дырки под крепление вентиятора
    for (i = [-1:2:1]) for (j = [-1:2:1])
            translate([i*l8/2, -1, l7/2+j*l8/2])
                rotate([-90, 0, 0]) 
                    cylinder(d = d2, h = l2 - l12+2);
    
    // дырки для крепления к радиатору
    for (i = [-1:2:1]) 
        translate([i*l18/2, -1, l7 - l17])
            rotate([-90, 0, 0]) cylinder(d = d3, h = l2 - l12+2);
    
    // Дырки в основном корпусе под сопла
    translate([-(t3-l4+l1+dl), t1-l11+l1, l1])
        cube([2*(t3-l4+l1+dl), l11-2*l1, l9-2*l1+2*dl]);
}

// Левое сопло
translate([-(t3-l4), t1, 0])
    rotate([90, 0, 0])
        soplo();

// Правое сопло
translate([t3-l4, t2, 0])
    rotate([90, 0, 180])
        soplo();

