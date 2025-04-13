function show_objective_function()
    t = linspace(0, 10, 100);
    r = linspace(0, 15, 100);

    [T, R] = meshgrid(t, r);

    Z = arrayfun(@(t, r) objective_function([t, r]), T, R);

    figure;
    surf(T, R, Z);
    xlabel('T-axis');
    ylabel('R-axis');
    zlabel('cost-axis');
    title('Example Function Surface Plot');
    colorbar;
    grid on;
    view(45, 30); % Adjust the view angle for better visualization
end