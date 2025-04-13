function drawcircle(x, y, r)
    if nargin < 3
        r = 5; % Default radius if not provided
    end

    mi_addnode(x + r, y);
    mi_addnode(x - r, y);
    mi_addarc(x + r, y, x - r, y, 180, 5);
    mi_addarc(x - r, y, x + r, y, 180, 5);

end