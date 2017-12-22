% This program simulates the gaussian noise generator and generates the
% reference output waveform for RTL testbench verification

input = load('unif_input.dat','-ascii','x_in') ;
coeff = load('fit_coeff.dat','-ascii','p_mem_block');

seg_num = 8;
factor_in = zeros(1,15);
cof_bit = 18;
factor_coeff = zeros(1,cof_bit);  % 3.15
fract_bit = 15;
awgn_out = zeros(1,10000);
offset_num = 32;

for j = 1:cof_bit
    if j == 1
        factor_coeff(j) = -2^(cof_bit-1-fract_bit);
    else
        factor_coeff(j) = 2^(cof_bit-fract_bit-j);
    end
end

for i = 1:10000  % 10,000 samples at input MEM
                 % note: i = 2 correspond to fpga's first input
    wf = input(i,:)       ;
    sgn = wf(64)           ;
    new_unif_in = (wf(44:58)); % scale to 0.5 - 1
    lzd_in = (wf(1:58))   ;
    offset = 16*wf(59)+ 8*wf(60)+4*wf(61) + 2*wf(62) + 1 * wf(63);%0 - 31
    zero_pos = 0          ;
    for j = 1:60
        if(lzd_in(j) == 0)
            zero_pos = j  ;
            break;
        end
    end
    if zero_pos == 0
        seg_num = 1;
    end
    if zero_pos == 1 
        seg_num = 1;
    end
    if zero_pos == 2
        seg_num = 2;
    end
    if zero_pos == 3
        seg_num = 3;
    end
    if zero_pos == 4
        seg_num = 4;
    end
    if zero_pos == 5
        seg_num = 5;
    end
    if zero_pos == 6
        seg_num = 6;
    end
    if zero_pos == 7
        seg_num = 7;
    end
    if zero_pos >= 8
        seg_num = 8;
    end
    %if zero_pos == 9
    %    seg_num = 9;
    %end
    %if zero_pos >= 10
    %    seg_num = 10;
    %end
    
    try1 = 1;
    for q = 1:15
        %factor_in(q) = 2^-(q+seg_num+ 1 + log2(offset_num));
        factor_in(q) = 2^-(q+try1+1 + log2(offset_num));
    end
    coeff1 = coeff(1:cof_bit, seg_num * offset_num - offset_num + 1 + offset);
    coeff2 = coeff(cof_bit+1:2*cof_bit,seg_num * offset_num - offset_num + 1 + offset);
    coeff3 = coeff(2*cof_bit+1:3*cof_bit,seg_num * offset_num - offset_num + 1 + offset);
    coeff1_num = dot(coeff1,factor_coeff);
    coeff2_num = dot(coeff2,factor_coeff);
    coeff3_num = dot(coeff3,factor_coeff);
    unif_in =  dot((new_unif_in),factor_in);
    awgn_out(i) = polyval([coeff1_num,coeff2_num,coeff3_num],unif_in);
    if sgn == 1
        awgn_out(i) = awgn_out(i)*-1;
    end
end
%awgn_out = awgn_out ./ sqrt(mean(awgn_out.^2));
%awgn_out = awgn_out - mean(awgn_out);
%awgn_out = awgn_out/max(awgn_out);
plot(awgn_out);
[h,p] = kstest(awgn_out,'alpha',0.05);
display(h);
display(p);
if h == 0
    display('Matlab test sucessful!');
else
    display('Matlab test failed!');
end
    
%save('matlab_result.dat','-ascii','awgn_out');



% for RTL ROM initialization %
% d = transpose(num2str(coeff(:,1)));
% display(d); %copy printed value to Vivado ROM init

