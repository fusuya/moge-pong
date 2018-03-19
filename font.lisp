(defparameter *font_default_Width* 80)
(defparameter *font_default_Height* 100)
(defparameter *position* (list 0 0))
(defparameter *fontheight* *font_default_height*)
(defparameter *fontcolor* (make-array 3))
(defparameter *weight* 10)


(defun fontBegin ()
  (gl:push-matrix)
  (gl:push-attrib :all-attrib-bits)
  (gl:matrix-mode :projection)
  (gl:load-identity) ;;初期化
 
  (glu:ortho-2d 0 *windowwidth* *windowHeight* 0)

  (gl:matrix-mode :modelview)
  (gl:load-identity)
  
  (gl:disable :depth-test)
  (gl:disable :lighting)
  (gl:disable :texture-2d))

(defun fontend ()
  (gl:pop-matrix)
  (gl:pop-attrib))

(defun fontSetPosition (x y)
  (setf (car *position*) x
        (cadr *position*) y))

(defun fontSetHeight (height)
  (setf *fontheight* height))

(defun fontGetHeight ()
   *fontheight*)

(defun fontGetWeightMin ()
  (aref (gl:get-float :line-width-range) 0))



(defun fontGetWeightMax ()
  (aref (gl:get-float :line-width-range) 1))

(defun fontSetWeight (weight)
  (setf *weight* weight))

(defun fontGetWeight ()
  *weight*)

;;フォント描画
(defun fontDraw (string)
  (gl:line-width *weight*)
  ;;フォントカラー

  (gl:push-matrix)
  (gl:translate (car *position*) (+ (cadr *position*) *fontheight*) 0)
  (let ((s (/ *fontheight* *font_default_height*))
	(num 0) (kai nil))
    (gl:scale s (- s) s)
    (loop for c across string
       do (if (equal c #\newline)
	      (progn (setf kai t)
		     (incf num)
		     (return))
	      (progn (incf num)
		     (glut:stroke-character glut:+stroke-roman+ (char-code c)))))
    (gl:pop-matrix)
    (if kai
	(progn (gl:translate 0 (+ *fontheight* *weight*) 0)
	       (fontdraw (subseq string num))))))
