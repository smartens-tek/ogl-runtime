/****************************************************************************
**
** Copyright (C) 2018 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of Qt 3D Studio.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "q3dsdatainput_p.h"
#include "q3dspresentation_p.h"
#include "q3dscommandqueue_p.h"

#include <QtCore/qdebug.h>

QT_BEGIN_NAMESPACE

/*!
    \qmltype DataInput
    \instantiates Q3DSDataInput
    \inqmlmodule QtStudio3D.OpenGL
    \ingroup OpenGLRuntime
    \brief Controls a data input entry in a Qt 3D Studio presentation.

    This class is a convenience class for controlling a data input in a presentation.
    DataInput provides a clean contract between the presentation design and the code.
    It hides the presentation details from the code while providing a contractual access
    point to code for controlling aspects of the presentation (e.g. timeline of a
    subpresentation). It also allows the design to use a single DataInput to drive
    multiple aspects of the design (e.g. DataInput for speed can change the color of
    the speedometer, angle of the needle).

    As an example:

    \qml
        Studio3D {
            ...
            Presentation {
                id: presentation
                ...
                property string text: ""
                DataInput {
                    name: "inputForSomeTextNode"
                    value: presentation.text
                }
            }
        }

        Button {
            onClicked: presentation.text = "Hello World"
        }
    \endqml

    The example assumes that a data input connection was made in Qt 3D Studio
    presentation using Qt 3D Studio editor between the \c textstring property of
    target property and a data input name \c inputForSomeTextNode. As the value
    is now set via a property, the full set of QML property bindings techniques
    are available.

    \note There is a performance cost for each registered DataInput, so try to avoid
    creating unnecessary DataInputs.

    \sa Presentation, DataOutput
    \sa {QtStudio3D.OpenGL::Presentation::slideExited()}{Presentation.slideExited()}
    \sa {QtStudio3D.OpenGL::Presentation::slideEntered()}{Presentation.slideEntered()}
    \sa {QtStudio3D.OpenGL::Presentation::customSignalEmitted()}{Presentation.customSignalEmitted()}
*/

/*!
    \class Q3DSDataInput
    \inmodule OpenGLRuntime
    \since Qt 3D Studio 2.0
    \brief Controls a data input entry in a Qt 3D Studio presentation.
    This class is a convenience class for controlling a data input in a presentation.
    DataInput provides a clean contract between the presentation design and the code.
    It hides the presentation details from the code while providing a contractual access
    point to code for controlling aspects of the presentation (e.g. timeline of a
    subpresentation). It also allows the design to use a single DataInput to drive
    multiple aspects of the design (e.g. DataInput for speed can change the color of
    the speedometer, angle of the needle).

    \note There is a performance cost for each registered DataInput, so try to avoid
    creating unnecessary DataInputs.

    For other integration points between code and presentation see:
    \sa Q3DSPresentation::customSignalEmitted
    \sa Q3DSPresentation::slideEntered
    \sa Q3DSPresentation::slideExited
    \sa Q3DSDataOutput

    \sa Q3DSPresentation
*/

/*!
    \internal
 */
Q3DSDataInput::Q3DSDataInput(QObject *parent)
    : QObject(parent)
    , d_ptr(new Q3DSDataInputPrivate(this))
{
}

/*!
    \internal
 */
Q3DSDataInput::Q3DSDataInput(const QString &name, QObject *parent)
    : QObject(parent)
    , d_ptr(new Q3DSDataInputPrivate(this))
{
    d_ptr->m_name = name;
}

/*!
    \fn Q3DSDataInput::Q3DSDataInput(Q3DSPresentation *presentation, const QString &name, QObject *parent)

    Constructs a Q3DSDataInput instance and initializes the \a name. The
    constructed instance is automatically associated with the specified \a
    presentation. An optional \a parent object can be specified.
 */
Q3DSDataInput::Q3DSDataInput(Q3DSPresentation *presentation, const QString &name, QObject *parent)
    : QObject(parent)
    , d_ptr(new Q3DSDataInputPrivate(this))
{
    d_ptr->m_name = name;
    d_ptr->m_presentation = presentation;
    if (presentation)
        presentation->registerDataInput(this);
}

/*!
    \internal
 */
Q3DSDataInput::Q3DSDataInput(Q3DSDataInputPrivate *d, Q3DSPresentation *presentation,
                             const QString &name, QObject *parent)
    : QObject(parent)
    , d_ptr(d)
{
    d_ptr->m_name = name;
    d_ptr->m_presentation = presentation;
    if (presentation)
        presentation->registerDataInput(this);
}

/*!
    Destructor.
 */
Q3DSDataInput::~Q3DSDataInput()
{
    delete d_ptr;
}

/*!
    \qmlproperty string DataInput::name

    Specifies the name of the controlled data input element in the
    presentation. The name must match a name of a data input defined
    in the presentation. This property must be set before setting the
    value property.
 */

/*!
    \property Q3DSDataInput::name

    Specifies the name of the controlled data input element in the
    presentation. The name must match a name of a data input defined
    in the presentation.

    This property must be set before setting the value property.
    The initial value is provided via the constructor, but the name
    can also be changed later on.
 */
QString Q3DSDataInput::name() const
{
    return d_ptr->m_name;
}

void Q3DSDataInput::setName(const QString &name)
{
    if (d_ptr->m_name != name) {
        d_ptr->m_name = name;
        if (d_ptr->m_presentation)
            d_ptr->m_presentation->registerDataInput(this);
        Q_EMIT nameChanged();
    }
}

/*!
    \qmlproperty variant DataInput::value

    Specifies the value of the controlled data input element in the
    presentation.

    The value of this property only accounts for changes done via the same
    Q3DSDataInput instance. If the value of the same data input in the
    presentation is changed elsewhere, for example via animations or
    Q3DSPresentation::setAttribute(), those changes are not reflected in the
    value of this property.

    To get actual values from the presentation, use DataOutput.
    \sa DataOutput
*/
/*!
    \property Q3DSDataInput::value

    Specifies the value of the controlled data input element in the
    presentation.

    The value of this property only accounts for changes done via the same
    Q3DSDataInput instance. If the value of the same data input in the
    presentation is changed elsewhere, for example via animations or
    Q3DSPresentation::setAttribute(), those changes are not reflected in the
    value of this property.

    To get actual values from the presentation, use DataOutput.
    \sa DataOutput
*/
QVariant Q3DSDataInput::value() const
{
    return d_ptr->m_value;
}

/*!
   \property Q3DSDataInput::min

    Contains the minimum range value for datainput. Returned value is zero
    for datainput types other than \e {Ranged Number}.

    \note This value is read-only.
 */
float Q3DSDataInput::min() const
{
    if (!d_ptr->m_presentation)
        return 0.0f;

    return d_ptr->m_presentation->d_ptr->dataInputMin(d_ptr->m_name);
}

/*!
    \property Q3DSDataInput::max

    Contains the maximum range value for datainput. Returned value is zero
    for datainput types other than \e {Ranged Number}.

    \note This value is read-only.
 */
float Q3DSDataInput::max() const
{
    if (!d_ptr->m_presentation)
        return 0.0f;

    return d_ptr->m_presentation->d_ptr->dataInputMax(d_ptr->m_name);
}

/*!
    Returns true if presentation (or its subpresentation) associated with
    this datainput has a datainput definition with a matching name. Returns
    false if the datainput has no associated presentation, or if a match is not found.
 */
bool Q3DSDataInput::isValid() const
{
    if (d_ptr->m_presentation)
        return d_ptr->m_presentation->d_ptr->isValidDataInput(this);
    else
        return false;
}

/*!
    \qmlmethod string DataInput::metadata(string key)

    Returns the metadata defined for this datainput with metadata \a key.

    Metadata is user-defined key-value table that can be used, for example, to better describe the
    usage of, or to indicate the external data source that should be bound to this datainput.
    Metadata has no impact on presentation rendering.

    \note Datainput metadata is read-only.
 */

/*!
    Returns the metadata defined for this datainput with metadata \a key.

    Metadata is user-defined key-value table that can be used, for example, to better describe the
    usage of, or to indicate the external data source that should be bound to this datainput.
    Metadata has no impact on presentation rendering.

    \note Datainput metadata is read-only.
 */
QString Q3DSDataInput::metadata(const QString &key) const
{
    if (!d_ptr->m_presentation)
        return {};

    auto metadata = d_ptr->m_presentation->d_ptr->dataInputMetadata(name());

    return metadata[key];
}

/*!
    Returns the metadata keys defined for this datainput.

    \sa metadata
 */
QStringList Q3DSDataInput::metadataKeys() const
{
    if (!d_ptr->m_presentation)
        return {};

    return d_ptr->m_presentation->d_ptr->dataInputMetadata(name()).keys();
}

/*!
    \brief Q3DSDataInput::setValue Set a new \a value for this data input.

    SetValue calls are batched within a single frame period. The most recently set \a value will be
    used to commit a change event for the runtime engine at the end of frame period. By default,
    a change event is only created if the new \a value is actually different from the previous
    frame's committed value.

    Use \a force parameter to force commit a change. This can be useful in situations where the
    target element property is being changed by several controllers, and the caller wants to be
    certain that value change will be processed. Note that animations take precedence over
    datainput control.

    \note For performance reasons do not call setValue with \a force set to true unnecessarily.
 */
void Q3DSDataInput::setValue(const QVariant &value, bool force)
{
    d_ptr->setValue(value, force);
    Q_EMIT valueChanged();
}

void Q3DSDataInputPrivate::setPresentation(Q3DSPresentation *presentation)
{
    m_presentation = presentation;
}

void Q3DSDataInputPrivate::setDirty(bool dirty)
{
    m_dirty = dirty;
}

void Q3DSDataInputPrivate::setCommittedValue(const QVariant &value)
{
    m_committedValue = value;
}

Q3DSDataInputPrivate::Q3DSDataInputPrivate(Q3DSDataInput *parent)
    : q_ptr(parent)
{
}

Q3DSDataInputPrivate::~Q3DSDataInputPrivate()
{
    if (m_presentation)
        m_presentation->unregisterDataInput(q_ptr);
}

void Q3DSDataInputPrivate::setValue(const QVariant &value, bool force)
{
    // Was there a force set at some point during this frame? If so, then inherit force flag
    // to all value set calls after it so that we do not discard the forced change.
    if (!m_forced)
        m_forced = force;

    m_value = value;
    setDirty(true);

    if (m_presentation)
        m_presentation->setDataInputValue(m_name, m_value, m_forced);
}

void Q3DSDataInputPrivate::setViewerApp(Q3DSViewer::Q3DSViewerApp *app)
{
    m_viewerApp = app;

    if (m_viewerApp && m_value.isValid())
        setValue(m_value);
}

void Q3DSDataInputPrivate::setCommandQueue(CommandQueue *queue)
{
    m_commandQueue = queue;

    if (m_commandQueue && m_value.isValid())
        setValue(m_value);
}

/*!
    \qmlproperty real DataInput::min

    Contains the minimum value of the controlled data input element range.

    This property is applicable only to data input type \e {Ranged Number}. For other
    types, value returned is zero.

    \note This value is read-only.
*/

/*!
    \qmlproperty real DataInput::max

    Contains the maximum value of the controlled data input element range.

    This property is applicable only to data input type \e {Ranged Number}. For other
    types, value returned is zero.

    \note This value is read-only.
*/

/*!
    \qmlproperty list<string> DataInput::metadataKeys

    Contains the metadata keys specified for this datainput.

    \note This value is read-only.
*/

/*!
    \property Q3DSDataInput::metadataKeys

    Contains the metadata keys specified for this datainput.

    \note This value is read-only.
*/

/*!
    \qmlmethod list<string> DataInput::metadataKeys

    Contains the metadata keys specified for this datainput.
*/

QT_END_NAMESPACE
