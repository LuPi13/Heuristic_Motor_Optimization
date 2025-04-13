function add_label(x, y, name, angle, group)
    mi_clearselected();
    mi_addblocklabel(x, y);
    mi_selectlabel(x, y);
    mi_setblockprop(name, 1, 0, 'None', angle, group, 0);
    mi_clearselected();
end