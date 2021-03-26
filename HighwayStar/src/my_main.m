clear
disp('Program started');
vrep = remApi('remoteApi');
vrep.simxFinish(-1);
clientID = -1;
while clientID <= -1
    clientID = vrep.simxStart('127.0.0.1', 19999, true, true, 5000, 5);
end

if (clientID > -1)
    disp('Connected to remote API server');
    vrep.simxSynchronous(clientID, true);
    % simx_opmode_oneshot表示我把数据发出去之后就开始执行后面的语句，不管你发完了没
    vrep.simxStartSimulation(clientID, vrep.simx_opmode_oneshot);

    % simx_opmode_blocking 确保这句话执行完了才会执行下一步
    [~, handle] = vrep.simxGetObjectHandle (clientID, 'Vision_sensor', vrep.simx_opmode_blocking);
    [~, left_handle] = vrep.simxGetObjectHandle (clientID, 'Pioneer_p3dx_leftMotor', vrep.simx_opmode_blocking);
    [~, right_handle] = vrep.simxGetObjectHandle (clientID, 'Pioneer_p3dx_rightMotor', vrep.simx_opmode_blocking);
    
    t = clock;
    currentTime = t(5) * 60 + t(6);
    startTime = t(5) * 60 + t(6);
    out = 0;
    max_force = 1;
    v_max = 3;
    direction = 0;
    while (currentTime - startTime < 30000)   
        % arr 是图像的分辨率，相当于图像的大小。
        [~, size, image] = vrep.simxGetVisionSensorImage2(clientID, handle, 1, vrep.simx_opmode_oneshot); 
        if isempty(image)
           continue 
        end
        [v_max, a_out, size_y, issharp, direction] = image_process(image, direction, v_max);
        % 这里的out是加速度？还是速度？之类的东西。
        [out, error] = dir_cmd(a_out, size_y);
        out1 = out;
        out2 = -out;
        vrep.simxPauseCommunication(clientID, 1);
        if(out > v_max)
            out1 = v_max;
            out2 = -v_max;
        end
        if(out < -v_max)
            out1 = -v_max;
            out2 = v_max;
        end
        % 如果是急转弯，那速度不由PID控制决定
        if (issharp)
            if (direction == 1)
%                 disp('left')
                out1 = -1 * v_max;
                out2 = 1 * v_max;
            else
%                 disp('right')
                out1 = 1 * v_max;
                out2 = -1 * v_max;
            end
        end
        v1 = v_max + out1;
        v2 = v_max + out2;
        vrep.simxSetJointTargetVelocity(clientID, left_handle, v1, vrep.simx_opmode_oneshot);
        vrep.simxSetJointTargetVelocity(clientID, right_handle, v2, vrep.simx_opmode_oneshot);
        vrep.simxPauseCommunication(clientID, 0);
        currentTime = currentTime + 10;
        vrep.simxSynchronousTrigger(clientID);
    end
    vrep.simxStopSimulation(clientID,vrep.simx_opmode_blocking); 
    vrep.simxFinish(clientID);
else
    disp('Failed connecting to remote API server');
end
vrep.delete();
disp('Program ended');