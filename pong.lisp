(ql:quickload '(:cl-glu :cl-glut :cl-opengl :cl-openal :cl-alc :cl-alut))
(load "font.lisp")
(load "rect.lisp")
(load "ball.lisp")
(load "paddle.lisp")
(load "audio.lisp")

(defparameter *player_max* 2)
(defparameter *windowWidth* 800)
(defparameter *windowHeight* 600)
(defparameter *angle* 0)
(defparameter *keys* (make-array 256 :initial-element nil))
;;m_position m_size (x y)

(defparameter *speed* 4)
(defparameter *ball* (make-ball :m_radius 8 :m_speed (list *speed* *speed*)))

(defparameter *paddles* (make-array *player_max*))
(defparameter *paddle-w* 6)
(defparameter *paddle-h* 48)

(defparameter *scores* (make-array *player_max*))
(defparameter *score-max* 11)
(defparameter *wait* 0)
(defparameter *started* nil)
(defparameter *paddle_speed* 8)
(defparameter *ball_y_speed_max* 16)

(defclass Window (glut:window)
  ()
  (:default-initargs
      :title "opengl test" :width *windowWidth* :height *windowheight*
    :mode '(:double :rgb) :tick-interval (round (/ 1000 60))))

(defmethod glut:display-window :before ((window Window))
  (gl:clear-color 0 0 0 1))


;;display
(defmethod glut:display ((window Window))
  (gl:clear :color-buffer-bit)
  ;;行列
  (gl:matrix-mode :projection)
  (gl:load-identity) ;;初期化
  (glu:ortho-2d 0 *windowwidth* *windowheight* 0)

  (gl:matrix-mode :modelview)
  (gl:load-identity)

  ;;センターライン
  (let ((line-w (gl:get-float :line-width-range)))
    (gl:line-width (aref line-w 1))
    (gl:push-attrib :all-attrib-bits)
    (gl:enable :line-stipple)
    (gl:line-stipple (aref line-w 1) #x5555)
    (gl:begin :lines)
    (dotimes (i 2)
      (%gl:vertex-2f (/ *windowwidth* 2) (* *windowheight* i)))
    (gl:end)
    (gl:pop-attrib))
  ;;ボール描画
  (if (<= *wait* 0)
      (draw *ball*))
  ;;パドルの描画
  (if *started*
      (loop for i from 0 below *player_max*
            do (draw (aref *paddles* i))))
  ;;フォント描画
  (fontbegin)
  (fontsetheight (/ *font_default_height* 1))
  (fontsetweight 10.0)
  (let* ((y (fontgetweight)))
    (loop for i from 0 below *player_max*
          do
             (fontsetposition (+ (- (/ *windowwidth* 4) 80)
                                 (* (/ *windowwidth* 2) i)) y)
             (fontdraw (format nil "~2d" (aref *scores* i))))) ;;文字列を渡す
  (fontend)
  
  (glut:swap-buffers))

;;tick
(defmethod glut:tick ((window Window))
  (audioUpdate *sid*)
  (if *started*
      (progn
        (if (> *wait* 0)
            (progn
              (decf *wait*)
              (if (and (<= *wait* 0)
                       (or (>= (aref *scores* 0) *score-max*)
                           (>= (aref *scores* 1) *score-max*)))
                  (setf *started* nil))))
	;;キーボード操作
          ;; (if (aref *keys* (char-code #\w))
          ;;     (decf (cadr (rect-m_position (aref *paddles* 0)))
	  ;; 	    *paddle_speed*))
          ;; (if (aref *keys* (char-code #\s))
          ;;     (incf (cadr (rect-m_position (aref *paddles* 0)))
          ;;           *paddle_speed*))
          ;; (if (aref *keys* (char-code #\j))
          ;;     (decf (cadr (rect-m_position (aref *paddles* 1)))
          ;;           *paddle_spped*))
          ;; (if (aref *keys* (char-code #\k))
          ;;     (incf (cadr (rect-m_position (aref *paddles* 1)))
          ;;           *paddle_spped*))
	  
	  ;;2P AI
	  (let ((centerY (+ (cadr (rect-m_position (aref *paddles* 1)))
			    (/ (cadr (rect-m_size (aref *paddles* 1))) 2))))
	    (if (< (cadr (ball-m_position *ball*)) (- centerY *paddle_speed*))
		(decf (cadr (rect-m_position (aref *paddles* 1)))
		      *paddle_speed*))
	    (if (> (cadr (ball-m_position *ball*)) (+ centerY *paddle_speed*))
		(incf (cadr (rect-m_position (aref *paddles* 1)))
		      *paddle_speed*)))
          (loop for i from 0 below *player_max*
                do
                   (setf (cadr (rect-m_position (aref *paddles* i)))
                         (max (cadr (rect-m_position (aref *paddles* i))) 0))
                   (setf (cadr (rect-m_position (aref *paddles* i)))
                         (min (cadr (rect-m_position (aref *paddles* i)))
                              (- *windowheight* (cadr (rect-m_size (aref *paddles* i)))))))))

  (if (<= *wait* 0)
      (progn
        (update *ball*)
        ;;ボールの跳ね返り
        ;;画面左右の当たり判定
        (if (or (< (car (ball-m_position *ball*)) 0)
                (>= (car (ball-m_position *ball*)) *windowwidth*))
            (if *started*
                (progn
		  (audiolength 1000)
		  (audiodecay 0)
		  (audiofreq (/ 440 4))
		  (audioplay *sid*)
                  (if (< (car (ball-m_position *ball*)) 0)
                      (incf (aref *scores* 1))
                      (incf (aref *scores* 0)))
                  (setf *wait* 60)
                  (setf (car (ball-m_position *ball*))
                        (/ *windowwidth* 2))
                  (setf (ball-m_lastposition *ball*)
                        (ball-m_position *ball*))
		  (setf (cadr (ball-m_speed *ball*))
			(max (cadr (ball-m_speed *ball*)) (- *paddle_speed*)))
		  (setf (cadr (ball-m_speed *ball*))
			(min (cadr (ball-m_speed *ball*)) *paddle_speed*)))
                ;;ゲームスタートしてなかったら  
                (setf ;;(ball-m_position *ball*)
                      ;;(ball-m_lastposition *ball*)
                      (car (ball-m_speed *ball*))
                      (- (car (ball-m_speed *ball*))))))
        ;;画面上下の当たり判定
        (if (or (< (cadr (ball-m_position *ball*)) 0)
                (>= (cadr (ball-m_position *ball*)) *windowheight*))
	    (progn
	      (if *started*
		  (progn
		    (audiodecay 0.9)
		    (audiofreq (/ 440 2))
		    (audioplay *sid*)))
	      (setf (ball-m_position *ball*)
		    (ball-m_lastposition *ball*)
		    (cadr (ball-m_speed *ball*))
		    (- (cadr (ball-m_speed *ball*))))))
        ;;パドルとボールの当たり判定
        (if *started*
            (loop for i from 0 below *player_max*
                  do
                     (if (intersectball (aref *paddles* i) *ball*)
                         (let ((paddleCenterY (+ (cadr (rect-m_position (aref *paddles* i))) (/ (cadr (rect-m_size (aref *paddles* i))) 2)))
                               (subMax (/ (cadr (rect-m_size (aref *paddles* i))) 2)))
			   ;;(audiowaveform 2)
			   (audiodecay 0.9)
			   (audiofreq 440)
			   (audioplay *sid*)
                           (setf (car (ball-m_speed *ball*))
                                 (- (car (ball-m_speed *ball*))))
                           
                           (setf (cadr (ball-m_speed *ball*))
                                 (* *ball_y_speed_max*
				    (/ (- (cadr (ball-m_position *ball*)) paddleCenterY) subMax)))))))))
  
  (glut:post-redisplay))


(defmethod glut:reshape ((window Window) width height)
  ;;(format t "reshape: width ~d height: ~d~%" width height)
  (gl:viewport 0 0 width height)
  (setf *windowwidth* width
        *windowheight* height))

(defmethod glut:keyboard ((window Window) key x y)
  (if (null *started*)
      (progn
        ;;パドル初期化
        (loop for i from 0 below *player_max*
              do
              ;;スコア初期化
              (setf (aref *scores* i) 0)
              ;;ボールのポジション真ん中
              (setf (car (ball-m_position *ball*))
                    (/ *windowwidth* 2)
                    (cadr (ball-m_position *ball*))
                    (/ *windowheight* 2))
              (setf (aref *paddles* i)
                    (make-rect :m_size (list *paddle-w* *paddle-h*)
                               :m_position
                               (if (= i 0)
                                   (list 100 (/ (- *windowheight* *paddle-h*) 2))
                                   (list (- *windowwidth* 100) (/ (- *windowheight* *paddle-h*) 2))))))
        (setf *started* t)))
  (case key
    (#\escape
     (audiostop *sid*)
     (glut:destroy-current-window)))
  (setf (aref *keys* (char-code key)) t))

(defmethod glut:keyboard-up ((window Window) key x y)
  ;;(format t "keyboard: ~c ~d~%" key (char-code key))
  (setf (aref *keys* (char-code key)) nil))

;;マウスモーション
(defmethod glut:passive-motion ((window Window) x y)
  ;;(format t "x: ~d y: ~d" x y)
  (setf (cadr (rect-m_position (aref *paddles* 0)))
	 y))
;;main
(defun main ()
 (alut:with-init
  ;;(alut:init)
  (setf *sid* (audioInit))
   (loop for i from 0 below *player_max*
	 do
	    (setf (aref *paddles* i)
                    (make-rect :m_size (list *paddle-w* *paddle-h*)
                               :m_position
                               (if (= i 0)
                                   (list 100 (/ (- *windowheight* *paddle-h*) 2))
                                   (list (- *windowwidth* 100) (/ (- *windowheight* *paddle-h*) 2))))))
  
  (setf *random-state* (make-random-state t))
  (glut:init)
  (glut:set-key-repeat :key-repeat-off)
  (glut:display-window (make-instance 'Window))))

