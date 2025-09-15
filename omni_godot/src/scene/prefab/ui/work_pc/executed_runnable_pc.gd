extends WorkerSubMenuPC
class_name ExecutedRunnablePC

@export var pid_label: RichTextLabel

@export var os_time_started_label: RichTextLabel
@export var active_label: RichTextLabel
@export var elapsed_label: RichTextLabel
@export var os_time_ended_label: RichTextLabel

var pinfo:Dictionary = {}

func _process(delta: float) -> void:
	if not pinfo.is_empty():
		if pinfo.has("elapsed"):
			var elapsed: float = pinfo.get("elapsed")
			elapsed_label.text = str(str(snappedf(elapsed, 0.001)) + "s")

func runnable_setup(runnable_info:Dictionary) -> void:
	toggle_body(false)
	pinfo = runnable_info
	var process_name: String = runnable_info.get("process_name")
	var new_pid: int = runnable_info.get("pid")
	var active: bool = runnable_info.get("active")
	
	var time_started: float = runnable_info.get("time_started")
	var elapsed: float = runnable_info.get("elapsed")
	var time_ended: float = runnable_info.get("time_ended")
	
	var os_time_started:Dictionary = runnable_info.get("os_time_started")#(Time.get_time_dict_from_system()))
	var os_time_ended:Dictionary = {}; if runnable_info.has("os_time_ended"): os_time_ended = runnable_info.get("os_time_ended")# Dictionary(Time.get_time_dict_from_system()))
	
	change_title(str(process_name))
	pid_label.text = str("PID: " + str(new_pid))
	
	os_time_started_label.text = str("a@: " + str(os_time_started.hour)+":"+str(os_time_started.minute)+":"+str(os_time_started.second))
	
	active_label.text = str("ACTIVE"); active_label.modulate = Color(0.25,1.0,0.25,1.0)
	if not active: active_label.text = str("DEAD"); active_label.modulate = Color(1.0,0.25,0.25,1.0)
	elapsed_label.text = str(str(elapsed) + "s")
	
	if os_time_ended.is_empty(): os_time_ended_label.text = str("b@: !")
	else: os_time_ended_label.text = str("b@: " + str(os_time_ended.hour)+":"+str(os_time_ended.minute)+":"+str(os_time_ended.second))
