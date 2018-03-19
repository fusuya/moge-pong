(defparameter *sid* nil)
(defparameter *waveform* 0)
(defparameter *buffers* nil)
(defparameter *oto-length* 0)
(defparameter *oto-start* 0)
(defparameter *oto-decay* 0)
(defparameter *default-gain* 0.5)
(defparameter *oto-gain* 0)
(defparameter *oto-sweep* 0)
(defparameter *default-freq* 440)
(defparameter *freqStart* *default-freq*)
(defparameter *freq* 0)
(defparameter *freqEnd* 0)

(defun audioInit ()
 (let ((source (al:gen-source))
       (palse '((#xff #x00 #x00 #x00 #x00 #x00 #x00 #x00)
		(#xff #xff #x00 #x00 #x00 #x00 #x00 #x00)
		(#xff #xff #xff #xff #x00 #x00 #x00 #x00)
		(#xff #xff #xff #xff #xff #xff #x00 #x00)))
       (triangle (cffi:foreign-alloc
                  :unsigned-char
                  :initial-contents
                  '(#xff #xee #xdd #xcc #xbb #xaa #x99 #x88 #x77 #x66 #x55 #x44 #x33 #x22 #x11 #x00 #x00 #x11 #x22 #x33 #x44 #x55 #x66 #x77 #x88 #x99 #xaa #xbb #xcc #xdd #xee #xff))))
   (setf *buffers* (al:gen-buffers 5))
    ;; AL:GET-ERROR somewhere about here
   ;; is generally a good idea.
   (loop for i from 0 to 3
      do (let ((data (cffi:foreign-alloc :unsigned-char
					 :initial-contents
					 (nth i palse))))
	   (al:buffer-data (nth i *buffers*) :mono8 data 8 (* 8 *default-freq*))
	   (cffi:foreign-free data)))
   (al:buffer-data (nth 4 *buffers*) :mono8 triangle 32 (* 32 *default-freq*))
   (cffi:foreign-free triangle)
   
    ;;(al:source source :pitch    1.0)
   
    ;;(al:source source :position sourcepos)
    ;;(al:source source :velocity sourcevel)
    (al:source source :looping  t)
    ;; GET-ERROR to see this all went smooth.
    (values source)))

(defun audioLength (millis)
  (setf *oto-length* millis))
  
(defun audioWaveform (waveform)
  (setf *waveform* waveform))

(defun audioDecay (decay)
  (setf *oto-decay* decay))

(defun audiosweep (sweep &optional (freqend 0))
  (setf *oto-sweep* sweep
        *freqend* freqend))


(defun audioFreq (freq)
  (setf *freqStart* freq))

(defun init-listener ()
  (al:listener :position    #(0 0 0))
  (al:listener :velocity    #(0 0 0))
  (al:listener :orientation #(0.0  0.0 -1.0
			      0.0 1.0 0.0)))

(defun audioPlay (sid)
  (al:source sid :gain (setf *oto-gain* *default-gain*))
  (setf *freq* *freqstart*)
  (al:source sid :pitch  (* 1.0 (/ *freq* *default-freq*)))
  (al:source sid :buffer (nth *waveform* *buffers*))
  (al:source-play sid)
  (setf *oto-start* (get-internal-real-time)))

(defun audioStop (sid)
  (al:source-stop sid))

(defun audioUpdate (sid)
  (if (and (> *oto-length* 0)
           (>= (- (get-internal-real-time) *oto-start*) *oto-length*))
      (audioStop sid))
  (if (and (/= *oto-decay* 0) (< *oto-decay* 1))
      (progn
        (setf *oto-gain* (* *oto-gain* *oto-decay*))
        (al:source sid :gain *oto-gain*)))
  (if (/= *oto-sweep* 0)
      (progn
        (setf *freq* (* *freq* *oto-sweep*))
        (if (/= *freqend* 0)
            (if (or (and (> *oto-sweep* 1) (>= *freq* *freqend*))
                    (and (< *oto-sweep* 1) (<= *freq* *freqend*)))
                (audioStop sid)))
                     
        (al:source sid :pitch (/ *freq* *default-freq*)))))
  
