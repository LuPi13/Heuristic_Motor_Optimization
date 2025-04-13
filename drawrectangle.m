function drawrectangle(x1, y1, x2, y2)
    mi_addnode(x1, y1);
    mi_addnode(x1, y2);
    mi_addnode(x2, y1);
    mi_addnode(x2, y2);
    mi_addsegment(x1, y1, x1, y2);
    mi_addsegment(x1, y2, x2, y2);
    mi_addsegment(x2, y2, x2, y1);
    mi_addsegment(x2, y1, x1, y1);
end