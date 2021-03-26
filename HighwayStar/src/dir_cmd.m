function [output, error] = dir_cmd(input, size_y)
    persistent last_err;
    if isempty(last_err)
        last_err = 0;
    end
    err = size_y / 2 - input;
    if(abs(err) < 0.5)
        output = 0;
    else
        output = err * 0.5 + 50 * (err - last_err);
    end
    %output = err * 0.5 + 50 * (err - last_err);
    last_err = err;
    error = abs(err);
end
