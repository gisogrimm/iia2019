function compute_SNR()
% Add paths to TASCAR and LSL Matlab tools
addpath('/usr/lib/lsl/');
addpath([pwd,'/mex']);
if exist('lsl_loadlib_') ~= 3
    cd('mex');
    build_lsl
    cd('..');
end
% TASCAR stuff:
javaaddpath('netutil-1.0.0.jar');
addpath('/usr/share/tascar/matlab');

% Create LSL inlets:
hLSL = lsl_loadlib('/usr/lib');
lslinlet = get_lsl_stream(hLSL, 'levels');
figure('NumberTitle','off','name','SNR benefit','menubar','none');
hold off;
yl = [-10,15];
xl = [-30,30];
plot(xl,[0,0],'k-');
hold on;
plot([15,15],yl,'k-');
plot([-15,-15],yl,'k-');
xlim(xl);
ylim(yl);
xlabel('SNR / dB');
ylabel('SNR benefit / dB');
text(0,-3,'detrimental','horizontalAlignment','center','FontSize',18);
text(0,3,'beneficial','horizontalAlignment','center','FontSize',18);
text(0.75*xl(2),0.9*yl(2),'easy','rotation',-90,'FontSize',18);
text(0,0.9*yl(2),'difficult','rotation',-90,'FontSize',18);
text(0.75*xl(1),0.9*yl(2),'unintelligible','rotation',-90,'FontSize',18);
h1 = plot(0,0,'-','Color',[0.9,0.1,0.1],'LineWidth',2);
h2 = plot(0,0,'-','Color',[0.1,0.1,0.9],'LineWidth',2);
while true
    levels = get_last_sample(lslinlet);
    snr_in = levels(1:2)-levels(3:4);
    snr_out = levels(5:6)-levels(7:8);
    set_arrow( h1, snr_in(1), snr_out(1) );
    set_arrow( h2, snr_in(2), snr_out(2) );
    pause(0.02);
end

function set_arrow( h, snr_in, snr_out )
b = snr_out-snr_in;
dx = -((b>0)-0.5)*4;
x = [snr_in;snr_in;snr_out;snr_out+dx;snr_out;snr_out+dx;snr_out];
y = [0;b;b;b+0.5;b;b-0.5;b];
set(h, 'XData', x, 'YData', y );

function bc = snrmapping( snr )
bc = max(-1,min(1,snr/15));

function [inlet,info] = get_lsl_stream( hLSL, name )
streams = lsl_resolve_bypred( hLSL, ['name=''',name,''''], 1, 10);
while isempty(streams)
    warning(['No stream ''',name,''' found.']);
    streams = lsl_resolve_bypred( hLSL, ['name=''',name,''''], 1, 10);
end
info = streams{1};
inlet = lsl_inlet(info);

function y = get_last_sample( inlet )
y = inlet.pull_chunk()';
if isempty(y)
    y = inlet.pull_sample();
else
    y = y(end,:);
end

