% This program exams different segments and generates the cheb coefficients
% The coeffients are stored in a .DAT to be put into the FPGA's MEM. 
resolution = 25;

stp = 0.5+ 2^(-resolution);
seg_num = 8; 
offset = 32;  % 5 offset bits
pfinal =ones(seg_num,3);
yfinal = [];
xfinal = [];
for i = 1:seg_num
    display(stp);
    display(stp + 2^(-i - 1));
    for j = 1:offset
        x0 = linspace(stp +  (j-1) * (2^(-i - 1))/offset ,stp + j * (2^(-i - 1))/offset,(2^resolution-i)/offset);
        y0 = norminv(x0);
        p = polyfit(x0,y0,2);
        yfit = polyval(p,x0);
        pfinal((i-1)*offset+j,:) = p;
        yfinal = [yfinal,yfit];
        xfinal = [xfinal,x0];
    end
   stp = stp + 2^(-i - 1);

end
x = linspace(0,1,1000);
y = norminv(x);
plot(x,y);
hold on;

plot(xfinal,yfinal,'r','linewidth',4);
legend('original ICDF','non-unif fitting (float)')
hold off;


% coeff transformation
%xba = 11; %11 bits, 2 offset and 9 segments
ptrans = zeros(seg_num*offset,3);
xa = zeros(seg_num*offset,1);
stp = 0;
for i = 1:seg_num*offset
    xba = 1 + log2(offset) + floor((i-1)/offset);
    if mod(i,offset) == 1
        stp = stp + offset*2^(-xba);
    end
    display(stp);
    fac = mod(i,offset);
    if fac == 0
        fac = offset;
    end
    xa(i) = stp + (fac - 1) * 2^(-xba-1);
    ptrans(i,3) = pfinal(i,3) + xa(i)*pfinal(i,2) + (xa(i)^2)*pfinal(i,1);
    ptrans(i,2) = 2*xa(i)*pfinal(i,1)/(2^xba) + pfinal(i,2)/2^xba;
    ptrans(i,1) = pfinal(i,1)/(2^(2*xba));
end

xfinal2 = [];
yfinal2 = [];
stp = 0.5;
for i = 1:seg_num
   display(stp);
   display(stp + 2^(-i-1));
   for j = 1:offset
    x0 = linspace(stp + (j-1) * (2^(-i - 1))/offset,stp + j * (2^(-i - 1))/offset,(2^resolution-i)/offset);
    xfinal2 = [xfinal2,x0];
    testx = x0 - stp - (j-1)* (2^(-i - 1))/offset;
    yeee = polyval([ptrans((i-1)*offset+j,1),ptrans((i-1)*offset+j,2),ptrans((i-1)*offset+j,3)],testx);
    yfinal2 = [yfinal2,yeee];
   end
   stp = stp + 2^(-i-1) ;
end

plot(x,y);
hold on;

plot(xfinal2,yfinal2,'r','linewidth',4);
legend('original ICDF','transformed coeff fit')
hold off;


cof_bit = 18;
fract_bit = 15;
p_mem_block = ones(cof_bit*3,seg_num*offset); %float to 3.15 2's complement
for i = 1:seg_num
    for k = 1:offset
      pk = [];
      for j = 1:3
        if ptrans((i-1)*offset+k,j) < 0
            % 3.15 2's complement
            new = dec2bin(2^(cof_bit+1) - abs(ptrans((i-1)*offset+k,j))*2^fract_bit,cof_bit);
            if length(new) == cof_bit + 1
                new = new(2:cof_bit + 1);
            end
            if ptrans((i-1)*offset+k,j) < -2^(cof_bit-1-fract_bit)
                new = dec2bin(2^(cof_bit-1),cof_bit);
            end
        else
            new = dec2bin((ptrans((i-1)*offset+k,j))*2^fract_bit,cof_bit);
        end
        pk = [pk , new];
      end
    for q = 1:cof_bit
       p_mem_block(q,(i-1)*offset+k) = str2num(pk(q));    % first coeff 18 bits
       p_mem_block(q+cof_bit,(i-1)*offset+k) = str2num(pk(q+cof_bit)); % second coeff 18 bits
       p_mem_block(q+cof_bit*2,(i-1)*offset+k) = str2num(pk(q+cof_bit*2)); % third coeff 18 bits
    end
   end
end


% test fixed point fiting performance
coeff1 = zeros(1,seg_num*offset);
coeff2 = zeros(1,seg_num*offset);
coeff3 = zeros(1,seg_num*offset);
factors = zeros(1,cof_bit);
for j = 1:cof_bit
    if j == 1
        factors(j) = -2^(cof_bit-1-fract_bit);
    else
        factors(j) = 2^(cof_bit-fract_bit-j);
    end
end

for i = 1:seg_num
    for j = 1:offset
        coeff1((i-1)*offset+j) = dot(p_mem_block(1:cof_bit,(i-1)*offset+j),factors);
        coeff2((i-1)*offset+j) = dot(p_mem_block(cof_bit+1:2*cof_bit,(i-1)*offset+j),factors);
        coeff3((i-1)*offset+j) = dot(p_mem_block(2*cof_bit+1:3*cof_bit,(i-1)*offset+j),factors);
    end
end
%coeff2 = pfinal(:,2);
stp = 0.5; %+ 2^-25;
yfinal1 = [];
xfinal1 = [];
for i = 1:seg_num
   display(stp);
   display(stp + 2^(-i-1));
   for j = 1:offset
    x0 = linspace(stp +  (j - 1) * (2^(-i - 1))/offset ,stp + j * (2^(-i - 1))/offset,(2^resolution-i)/offset);
    testx = x0 - stp - (j-1)* (2^(-i - 1))/offset;
    yfit = polyval([coeff1((i-1)*offset+j),coeff2((i-1)*offset+j),coeff3((i-1)*offset+j)],testx);
    yfinal1 = [yfinal1,yfit];
    xfinal1 = [xfinal1,x0];
   end
   stp = stp + 2^(-i - 1);
end

plot(x,y);
hold on;

plot(xfinal1,yfinal1,'r','linewidth',4);
legend('original ICDF','transformed coeff (fixed ptr)')
hold off;


% save as .dat coefficients file 
%save('fit_coeff.dat','-ascii','p_mem_block');
%m = load('fit_coeff.dat','-ascii','p_mem_block');



