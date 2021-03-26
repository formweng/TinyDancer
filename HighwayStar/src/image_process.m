% �ڶ�������last_d����һ�ε����ķ���
function [v_max, out, size_y, is_sharp, direction] = image_process(img, last_d, v)
    % �ж��Ƿ���Ҫ��ת���ж��������ڻ����·�ĳλ�û���һ����
    % ������û����·������Ϊ�Ǽ�ת�䡣
    is_sharp = 1;
    v_max = 3;% Ĭ��Ϊת��״̬ 3.5 ��̫�ȶ�
    % �����ڳ��ּ�ת������������жϼ�ת�ķ��򡣳�ʼ��Ϊ��һ�ε����ķ���
    direction = last_d;
    % ����ֵ��(size_y - out)��ֵ������ƫ���������ã�����PID���ơ�
    out = 0;
    img = imresize(img, 0.2);
    [size_x, size_y] = size(img);
    img = imbinarize(img);
    % 1Ϊ��·��0Ϊ�ǵ�·
    img = 1 - img;
    % ����ͨ����
    cclabel = bwlabel(img);
    
    % ��һ�δ�������������ͨ������
    % ��ԭ���������һ�е��м俪ʼ��Ϊ1�ĵ�
    % �ҵ��ĵ����ڵ���ͨ������������Ҫ�ҵ�
    % ������tmp��������ͨ������
    idx_tmp = size_y / 2;    % ƫ����
    cnt_tmp = 0;    % ƫ�����ľ���ֵ
    sign_tmp = 1;   % ������¼ƫ�����ķ���
    while cclabel(size_x, idx_tmp) == 0
        % (-1)^sign_tmp * cnt_tmp ��˳����-1,2,-3,4,-5,...
        cnt_tmp = cnt_tmp + 1;
        sign_tmp = 1 - sign_tmp;
        % �������з�ֹ��������Խ��
        idx_tmp = idx_tmp + (-1)^sign_tmp * cnt_tmp;
        if (idx_tmp > size_y || idx_tmp < 1)
            v_max = 1.5;
            return
        end
    end
    % �����������ڽ���������Ҫ����ͨ����
    img = zeros(size_x, size_y);
    img(cclabel == cclabel(size_x, idx_tmp)) = 1;
    
%     imshow(img);
        
    
    % win��window����˼���൱�ڿ��ǵĴ��ڡ�
    % ��������������������������������        y
    % ��������������������������������     ���� 
    % ��������������������������������    x��
    % ��������win_y��������������  ��
    % ��������������������������������
    % ��������������������win_x������
    % �������ة����������ة�����������
    %                  k1
    win_x = 10;
    win_y = size_y / 2;
    k1 = size_y / 2 + win_y / 2; % k1�Ǵ������½ǵ�y����
    cnt = 1;
    out = size_y / 2 * ones(win_x, win_y);  % ���ڼ�¼��·�����ƫ����
    line_x = round(95 / 100 * size_x);   % line_x���Ǿ�����ת�������ߵ�x����
    
    % ����Ĵ���Դ��ڵ��������ؽ��б�������ȷ��is_sharp��direction
    % ����˳���ǣ����ִ����Ӧ���±��ȥ����ַleft_tmp��ֵ�����細�ڵ�y_size��10����
    % 1,10,2,9,3,8,4,7,5,6
    left_tmp = size_y / 2 - win_y / 2 + 1;  % �൱�ڣ�����ʼ�ģ�����ַ
    right_tmp = size_y / 2 + win_y / 2 - 1; % �൱�ڣ����ҿ�ʼ�ģ�����ַ
    flag_tmp = 1;  % ���flag�������������������
    offset_tmp = 0;  % ƫ����
    while (offset_tmp <= win_y - 1)
        % ��������ȷ��line_y��Ҳ���Ǳ������ĵ��y����
        if (flag_tmp == 1)
            line_y = left_tmp + offset_tmp;
        else
            line_y = right_tmp - offset_tmp;
        end
        flag_tmp = 1 - flag_tmp;
        % ������������������offset_tmp��ÿ�����������offset_tmp�ͻ��1
        if flag_tmp == 1
            offset_tmp = offset_tmp + 1;
        end
        % ��������������ҵ����ˣ��Ͳ��Ǽ�ת
        if img(line_x, line_y) == 1
            is_sharp = 0;
            if line_y < size_y / 2
                direction = 1;      % 1��������ת
            else
                direction = 2;      % 2��������ת
            end
            break
        end
    end
    
    % ���´���Դ���ÿ������б�������ȷ������ֵout
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

% (size_x-win_x,(size_y-win_y)/2) ���Ͻ�
% (size_x-win_x,(size_y+win_y)/2) ���Ͻ�
% (size_x,(size_y-win_y)/2) ���½�
% (size_x,(size_y+win_y)/2) ���Ͻ�
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
