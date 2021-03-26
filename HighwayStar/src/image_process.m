% 第二个参数last_d是上一次迭代的方向
function [v_max, out, size_y, is_sharp, direction] = image_process(img, last_d, v)
    % 判断是否需要急转。判断依据是在画面下方某位置划定一条线
    % 这条线没穿过路径则认为是急转弯。
    is_sharp = 1;
    v_max = 3;% 默认为转弯状态 3.5 不太稳定
    % 仅用于出现急转的情况，用来判断急转的方向。初始化为上一次迭代的方向
    direction = last_d;
    % 返回值。(size_y - out)的值起到类似偏移量的作用，用于PID控制。
    out = 0;
    img = imresize(img, 0.2);
    [size_x, size_y] = size(img);
    img = imbinarize(img);
    % 1为道路，0为非道路
    img = 1 - img;
    % 找连通分量
    cclabel = bwlabel(img);
    
    % 这一段代码是用来找连通分量的
    % 其原理是在最后一行的中间开始找为1的点
    % 找到的点所在的连通分量就是我们要找的
    % 这三个tmp用来找连通分量的
    idx_tmp = size_y / 2;    % 偏移量
    cnt_tmp = 0;    % 偏移量的绝对值
    sign_tmp = 1;   % 用来记录偏移量的符号
    while cclabel(size_x, idx_tmp) == 0
        % (-1)^sign_tmp * cnt_tmp 的顺序是-1,2,-3,4,-5,...
        cnt_tmp = cnt_tmp + 1;
        sign_tmp = 1 - sign_tmp;
        % 以下四行防止出现索引越界
        idx_tmp = idx_tmp + (-1)^sign_tmp * cnt_tmp;
        if (idx_tmp > size_y || idx_tmp < 1)
            v_max = 1.5;
            return
        end
    end
    % 以下两行用于仅保留所需要的连通分量
    img = zeros(size_x, size_y);
    img(cclabel == cclabel(size_x, idx_tmp)) = 1;
    
%     imshow(img);
        
    
    % win是window的意思，相当于考虑的窗口。
    % ┌──────────────┐        y
    % │　　　　　　　　　　　　　　│     ┌→ 
    % │　　　　　　　　　　　　　　│    x↓
    % │　　　win_y　　　　　　　  │
    % │　　┌─────┐　　　　　│
    % │　　│　　　　　│win_x　　│
    % └──┴─────┴─────┘
    %                  k1
    win_x = 10;
    win_y = size_y / 2;
    k1 = size_y / 2 + win_y / 2; % k1是窗口右下角的y坐标
    cnt = 1;
    out = size_y / 2 * ones(win_x, win_y);  % 用于记录道路整体的偏移量
    line_x = round(95 / 100 * size_x);   % line_x就是决定急转的那条线的x坐标
    
    % 下面的代码对窗口的所有像素进行遍历，以确定is_sharp和direction
    % 遍历顺序是（数字代表对应点下标减去基地址left_tmp的值，假如窗口的y_size是10）：
    % 1,10,2,9,3,8,4,7,5,6
    left_tmp = size_y / 2 - win_y / 2 + 1;  % 相当于（从左开始的）基地址
    right_tmp = size_y / 2 + win_y / 2 - 1; % 相当于（从右开始的）基地址
    flag_tmp = 1;  % 这个flag是用来决定遍历方向的
    offset_tmp = 0;  % 偏移量
    while (offset_tmp <= win_y - 1)
        % 以下五行确定line_y，也就是遍历到的点的y坐标
        if (flag_tmp == 1)
            line_y = left_tmp + offset_tmp;
        else
            line_y = right_tmp - offset_tmp;
        end
        flag_tmp = 1 - flag_tmp;
        % 以下三行是用于增加offset_tmp，每遍历两个点后offset_tmp就会加1
        if flag_tmp == 1
            offset_tmp = offset_tmp + 1;
        end
        % 如果在这条线上找到点了，就不是急转
        if img(line_x, line_y) == 1
            is_sharp = 0;
            if line_y < size_y / 2
                direction = 1;      % 1代表向左转
            else
                direction = 2;      % 2代表向右转
            end
            break
        end
    end
    
    % 以下代码对窗口每个点进行遍历，以确定返回值out
    for i = 1 : win_x
        for j = 1 : win_y
            k2 = k1 + 1 - j;
            if (img(size_x + 1 - i, k2) == 1)
                out(i, cnt) = size_y + 1 - k2;
                cnt = cnt + 1;
            end
        end
        cnt = 1;
    end
    out = mean(out, 'all');
    out = round(out);

    if abs(out-size_y/2) >= 4 
        v_max = 3;
    elseif v >= 3 && v < 5
        v_max = v + 0.01;
    end

% (size_x-win_x,(size_y-win_y)/2) 左上角
% (size_x-win_x,(size_y+win_y)/2) 右上角
% (size_x,(size_y-win_y)/2) 左下角
% (size_x,(size_y+win_y)/2) 右上角
    x1 = size_x-win_x/2; 
    x2 = size_x;
    y1 = round((size_y-win_y)/2);
    y2 = round((size_y+win_y)/2);
    count = 0;
    temp = [0,img(x1,y1:y2),0];
    count = count + sum(diff(temp)~=0);
    temp = [0,img(x2,y1:y2),0];
    count = count + sum(diff(temp)~=0);
    temp = [0,img(x1:x2,y1)',0];
    count = count + sum(diff(temp)~=0);
    temp = [0,img(x1:x2,y2)',0];
    count = count + sum(diff(temp)~=0);
    if count == 8
        v_max = 10;
    end

    
    if is_sharp == 1
        direction = last_d;
    end
end
