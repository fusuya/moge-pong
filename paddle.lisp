
(defstruct paddle
  (m_position '(100 100))
  (m_height 0))

(defmethod draw ((paddle paddle))
  (gl:push-attrib :line-bit)
  (let ((w (aref (gl:get-float :line-width-range) 1)))
    (gl:line-width w)
    (gl:begin :lines)
    
    (%gl:vertex-2f (car (paddle-m_position paddle)) (cadr (paddle-m_position paddle)))
    (let ((v (mapcar #'+ (paddle-m_position paddle) (list 0 (paddle-m_height paddle)))))
      (%gl:vertex-2f (car v) (cadr v))
      
      (gl:end)
      (gl:pop-attrib))))

;;ボールとパドルの当たり判定
(defmethod intersectBall ((paddle rect) (ball ball))
  (if (or (and (< (car (ball-m_position ball))
		  (+ (car (rect-m_position paddle)) (car (rect-m_size paddle))))
	       (>= (car (ball-m_lastposition ball))
		   (+ (car (rect-m_position paddle)) (car (rect-m_size paddle)))))
	  (and (>= (car (ball-m_position ball))
		   (car (rect-m_position paddle)))
	       (< (car (ball-m_lastposition ball))
		  (car (rect-m_position paddle)))))
      (if (and (>= (cadr (ball-m_position ball))
		   (cadr (rect-m_position paddle)))
	       (< (cadr (ball-m_position ball))
		  (+ (cadr (rect-m_position paddle))
		     (cadr (rect-m_size paddle)))))
	  t
	  nil)
      nil))
