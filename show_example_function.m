function show_example_function()
    x = linspace(-5, 5, 100);
    y = linspace(-5, 5, 100);

    [X, Y] = meshgrid(x, y);

    Z = heuristic_example_function(X, Y);

    figure;
    surf(X, Y, Z);
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    title('Example Function Surface Plot');
    colorbar;
    grid on;
    view(45, 30); % Adjust the view angle for better visualization
end