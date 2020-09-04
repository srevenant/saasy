import React from 'react'
import style from './SignForm.module.scss'
import { TENANT } from '../../constants/AuthX'
import SignOnFederated from './SignOnFederated'
import SignOnLocal from './SignOnLocal'

////////////////////////////////////////////////////////////////////////////////
export function SignForm({ signout = undefined, ...args }) {
  // <div
  //   className={`${style.authx} flex items-start justify-center ${style.authbox} theme-frame`}
  // >
  //   <div className="w-100">
  //     <SignOnLocal boxPadding={boxPadding} />
  //     <div
  //       className={`${style.innerpane} ${boxPadding} items-center ba b--transparent pb1`}
  //     >
  //       <SignOnFederated tenant={TENANT} />
  //     </div>
  //     <div
  //       className={`${style.innerpane} ${boxPadding} pv2 pv3-m pv4-l items-center ba b--transparent`}
  //     >
  //       <div className="i f7 tc">
  //         <a href="/#/pwreset?request=yes">Forgot Password?</a>
  //       </div>
  //       {TENANT.terms}
  //     </div>
  //   </div>
  // </div>
  const boxPadding = 'ph3 ph4-ns'
  return (
    <div
      className={`${style.authbox} theme-frame flex items-start justify-center mb5`}
    >
      <div className="w-100">
        <SignOnLocal boxPadding={boxPadding} {...args} />
        <div className={`${boxPadding} items-center ba b--transparent pb1`}>
          <SignOnFederated tenant={TENANT} className={style.innerpane} />
        </div>
        <div
          className={`${boxPadding} pv2 pv3-m pv4-l items-center ba b--transparent`}
        >
          <div className="i f7 tc mb2">
            <a href="/#/pwreset?request=yes">Forgot Password?</a>
          </div>
          {TENANT.terms}
        </div>
      </div>
    </div>
  )
}

export default SignForm
