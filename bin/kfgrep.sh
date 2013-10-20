#!/bin/bash
#
# grep linux kernel init/exit functions

lk_kthread=('kthread_create' 'kthread_run' 'kthread_stop' )
lk_softirq=('open_softirq' 'raise_softirq' 'raise_softirq_irqoff' )
lk_timer=('init_timer' 'add_timer' 'mod_timer' 'del_timer' 'del_timer_sync' 'setup_timer' 'timer_pending' )
lk_tasklet=('DECLARE_TASKLET' 'DECLARE_TASKLET_DISABLED' 'tasklet_init'  'tasklet_schedule'  'tasklet_disable' 'tasklet_enable' )
lk_workqueue=('DECLARE_WORK' 'INIT_WORK' 'schedule_work' 'schedule_delayed_work'  'flush_scheduled_work' 'cancel_delayed_work' 'create_workqueue' 'queue_work' 'queue_delayed_work' 'flush_workqueue' )
lk_interrupt=('request_irq' 'free_irq' )
lk_complete=('complete' 'wait_for_completion_interruptible_timeout' 'wait_for_completion_interruptible' 'wait_for_completion' 'complete_and_exit')

linux_kernel_functions=(
			"${lk_kthread[@]}"
			"${lk_softirq[@]}"
			"${lk_timer[@]}"
			"${lk_tasklet[@]}"
			"${lk_workqueue[@]}"
			"${lk_interrupt[@]}"
			"${lk_complete[@]}"
			)

tmpfile=/tmp/lkgrep.txt
for f in ${linux_kernel_functions[@]}
do
	echo $f >>$tmpfile
done

grep --color=auto -F -f $tmpfile "$@"
